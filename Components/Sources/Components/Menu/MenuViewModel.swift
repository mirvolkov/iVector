import Combine
import Connection
import Features
import SwiftUI
import Programmator

final class MenuViewModel: ObservableObject, PickListPopoverCallback {
    @Published var memory: Bool = false
    @Published var batt: Image?
    @Published var prog: String? = nil
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
            .assign(to: \.isRunning, on: self)
            .store(in: &bag)

        executor.$running
            .map { $0?.name }
            .receive(on: RunLoop.main)
            .assign(to: \.prog, on: self)
            .store(in: &bag)

//        Task { @MainActor [self] in
//            await self.connection.battery
//                .receive(on: RunLoop.main)
//                .map {
//                    switch $0 {
//                    case .unknown:
//                        return nil
//                    case .charging:
//                        return .init(systemName: "battery.100.bolt")
//                    case .full:
//                        return .init(systemName: "battery.100")
//                    case .normal:
//                        return .init(systemName: "battery.50")
//                    case .low:
//                        return .init(systemName: "battery.25")
//                    }
//                }
//                .assign(to: \.batt, on: self)
//                .store(in: &self.bag)
//        }
    }

    func onProgTap() {
        items = executor.programs
        loadProgramPopover = true
    }

    func onCancelTap() {
        executor.cancel()
    }

    func onItemSelected(item: Program) {
        loadProgramPopover = false
        executor.run(program: item)
    }
}
