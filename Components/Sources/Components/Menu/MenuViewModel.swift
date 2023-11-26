import Combine
import Connection
import Features
import Programmator
import SwiftUI

public extension MenuView {
    final class ViewModel: ObservableObject, PickListPopoverCallback {
        @MainActor @Published var memory: Bool = false
        @MainActor @Published var prog: String?
        @MainActor @Published var items: [Program] = []
        @MainActor @Published var isProgRunning = false {
            didSet {
                isAIRunning = false // TODO: git rid when AIExecutor runs
            }
        }

        @MainActor @Published var isAIRunning = false
        @MainActor @Published var execError: ErrorHandlerViewModel? = nil

        private let connection: ConnectionModel
        private let executor: ExecutorModel
        private var bag = Set<AnyCancellable>()

        public init(with connection: ConnectionModel, executor: ExecutorModel) {
            self.connection = connection
            self.executor = executor
        }

        public func bind() {
            executor.$running
                .map { $0 != nil }
                .receive(on: RunLoop.main)
                .weakAssign(to: \.isProgRunning, on: self)
                .store(in: &bag)

            executor.$pc.combineLatest(executor.$running)
                .receive(on: RunLoop.main)
                .map { value in
                    guard let pc = value.0, let prog = value.1 else {
                        return nil
                    }
                    return "\(prog.name.prefix(8)) [\(pc.0)/\(pc.1)]"
                }
                .weakAssign(to: \.prog, on: self)
                .store(in: &bag)
        }

        func onProgTap() {
            Task { @MainActor [self] in
                items = try await AssemblerModel.programs
            }
        }

        func onAITap() {
            Task { @MainActor [self] in
                isAIRunning.toggle()
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
                        execError?.handle(error: error)
                        executor.cancel()
                    }
                }
            }
        }
    }
}
