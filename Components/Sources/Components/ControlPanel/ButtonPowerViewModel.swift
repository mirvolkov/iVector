import Combine
import Features
import SwiftUI

class ButtonPowerViewModel: ControlPanelButtonViewModel {
    @Published var enabled: Bool = true
    @Published var primaryIcon: Image?
    @Published var primaryTitle: String?
    @Published var secondaryTitle: String?
    @Published var tintColor: Color = .green
    @Published var isLoading: Bool = false
    
    public var onConnect: () -> Void = { }
    public var onDisconnect: () -> Void = { }

    private let connection: ConnectionModel
    private var bag = Set<AnyCancellable>()

    init(connection: ConnectionModel) {
        self.connection = connection
        self.primaryIcon = .init(systemName: "power")
    }

    func onClick() {
        Task { @MainActor [self] in
            switch await self.connection.state.value {
            case .disconnected:
                onConnect()
            case .online:
                onDisconnect()
            case .connecting:
                break
            }
        }
    }

    func bind() {
        Task { @MainActor [self] in
            await self.connection.state
                .map {
                    switch $0 {
                    case .connecting:
                        return .yellow
                    case .disconnected:
                        return .red
                    case .online:
                        return .green
                    }
                }
                .receive(on: RunLoop.main)
                .assign(to: \.tintColor, on: self)
                .store(in: &self.bag)
        }
    }

    func unbind() {
        bag.removeAll()
    }
}
