import Combine
import Connection
import Features
import Programmator
import SwiftUI

final class MenuViewModel: ObservableObject, PickListPopoverCallback {
    @MainActor @Published var memory: Bool = false
    @MainActor @Published var batt: Image? = .init(systemName: "battery.0")
    @MainActor @Published var prog: String = .init()
    @MainActor @Published var items: [Program] = []
    @MainActor @Published var isRunning = false
    @MainActor @Published var execError: Error? = nil

    private let connection: ConnectionModel
    private let executor: ExecutorModel
    private var bag = Set<AnyCancellable>()

    init(with connection: ConnectionModel, executor: ExecutorModel) {
        self.connection = connection
        self.executor = executor
    }

    func bind() {
        executor.$running
            .map { $0 != nil }
            .receive(on: RunLoop.main)
            .weakAssign(to: \.isRunning, on: self)
            .store(in: &bag)

        executor.$pc.combineLatest(executor.$running)
            .receive(on: RunLoop.main)
            .map { value in
                guard let pc = value.0, let prog = value.1 else {
                    return nil
                }
                return "\(prog.name.prefix(8)) [\(pc.0)/\(pc.1)]"
            }
            .replaceNil(with: "PROG")
            .weakAssign(to: \.prog, on: self)
            .store(in: &bag)

        Task { @MainActor [self] in
            while let battery = try await self.connection.battery {
                switch battery {
                case .unknown:
                    batt = nil
                case .charging:
                    batt = .init(systemName: "battery.100.bolt")
                case .full:
                    batt = .init(systemName: "battery.100")
                case .normal:
                    batt = .init(systemName: "battery.50")
                case .low:
                    batt = .init(systemName: "battery.25")
                case .percent(let value):
                    switch value {
                    case 0...25:
                        batt = .init(systemName: "battery.25")
                    case 25...50:
                        batt = .init(systemName: "battery.50")
                    case 50...100:
                        batt = .init(systemName: "battery.100")
                    default:
                        batt = .init(systemName: "battery.100.bolt")
                    }
                }

                try await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }

    func onProgTap() {
        Task { @MainActor [self] in
            items = try await AssemblerModel.programs
        }
    }

    func onCancelTap() {
        executor.cancel()
    }

    func onItemSelected(item: Program) {
        Task {
            do {
                try await executor.run(program: item)
            } catch {
                await MainActor.run {
                    self.execError = error
                }
            }
        }
    }
}
