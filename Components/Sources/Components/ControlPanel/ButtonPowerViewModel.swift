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

    private let connection: ConnectionModel
    private let settings: SettingsModel
    private var bag = Set<AnyCancellable>()

    init(connection: ConnectionModel, settings: SettingsModel) {
        self.connection = connection
        self.settings = settings
        self.primaryIcon = .init(systemName: "power")
    }

    func onClick() {
        Task { @MainActor [self] in
            switch await self.connection.state.value {
            case .disconnected:
                await connection.connect(with: settings.ip, port: settings.port)
            case .online:
                await connection.disconnect()
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
