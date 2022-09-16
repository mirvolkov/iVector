import Combine
import Features
import SwiftUI

extension ControlPanelButtonView {
    class ButtonPowerViewModel: ViewModel {
        @Published var isConnected: Bool = false {
            didSet {
                if isConnected {
                    Task {
                        try await connection.behavior?.setEyeColor(
                            settings.eyeColor.hsv.hueComponent,
                            settings.eyeColor.hsv.satComponent
                        )
                    }
                }
            }
        }

        private let connection: ConnectionModel
        private let settings: SettingsModel
        private var bag = Set<AnyCancellable>()

        init(connection: ConnectionModel, settings: SettingsModel) {
            self.connection = connection
            self.settings = settings
            super.init()
            self.primaryIcon = .init(systemName: "power")
        }

        override func onClick() {
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

        override func bind() {
            Task { @MainActor [self] in
                await self.connection.state
                    .receive(on: RunLoop.main)
                    .map { newState in if case .online = newState { return true } else { return false } }
                    .assign(to: \.isConnected, on: self)
                    .store(in: &self.bag)

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

                await self.connection.state
                    .map {
                        switch $0 {
                        case .connecting:
                            return false
                        default:
                            return true
                        }
                    }
                    .receive(on: RunLoop.main)
                    .assign(to: \.enabled, on: self)
                    .store(in: &self.bag)
            }
        }
    }
}
