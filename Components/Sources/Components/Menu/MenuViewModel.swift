import Combine
import Connection
import Features
import SwiftUI
import Programmator

final class MenuViewModel: ObservableObject, PickListPopoverCallback {
    @Published var memory: Bool = false
    @Published var batt: Image? = .init(systemName: "battery.0")
    @Published var prog: String = .init()
    @Published var items: [Program] = []
    @Published var isRunning = false
    @Published var loadProgramPopover = false

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
            await self.connection.battery
                .receive(on: RunLoop.main)
                .map {
                    switch $0 {
                    case .unknown:
                        return nil
                    case .charging:
                        return .init(systemName: "battery.100.bolt")
                    case .full:
                        return .init(systemName: "battery.100")
                    case .normal:
                        return .init(systemName: "battery.50")
                    case .low:
                        return .init(systemName: "battery.25")
                    }
                }
                .weakAssign(to: \.batt, on: self)
                .store(in: &self.bag)
        }
    }

    func onProgTap() {
        do {
            items = try executor.programs
            loadProgramPopover = true
        } catch {
            print(error)
        }
    }

    func onCancelTap() {
        executor.cancel()
    }

    func onItemSelected(item: Program) {
        loadProgramPopover = false
        executor.run(program: item)
    }
}
