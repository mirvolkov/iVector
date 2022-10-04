import Combine
import Connection
import Features
import SwiftUI

final class MenuViewModel: ObservableObject {
    @Published var memory: Bool = false
    @Published var batt: Image?
    @Published var prog: String? = nil
    @Published var programs: [String] = ["A", "B"]
    @Published var isRunning = false
    @Published var loadProgramPopover = false

    private let connection: ConnectionModel
    private var bag = Set<AnyCancellable>()

    init(with connection: ConnectionModel) {
        self.connection = connection
    }

    func bind() {
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
                .assign(to: \.batt, on: self)
                .store(in: &self.bag)
        }
    }

    func onProgTap() {}

    func onCancelTap() {}
}
