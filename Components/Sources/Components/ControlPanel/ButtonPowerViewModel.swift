import Combine
import Features
import SwiftUI

class ButtonPowerViewModel: ControlPanelButtonViewModel {
    @Published var disableSecondary: Bool = false
    @Published var disableTitle: Bool = false
    @Published var disableIcon: Bool = false
    @Published var enabled: Bool = true
    @Published var primaryIcon: Image?
    @Published var primaryTitle: String?
    @Published var secondaryTitle: String?
    @Published var tintColor: Color = .green
    @Published var isLoading: Bool = false
    @Published var tag: CPViewModelTag?

    public var onConnect: () -> Void = {}
    public var onDisconnect: () -> Void = {}

    private let connection: ConnectionModel
    private var bag = Set<AnyCancellable>()

    init(connection: ConnectionModel) {
        self.connection = connection
        self.primaryIcon = .init(systemName: "power")
    }

    func onClick() {
        switch connection.state.value {
        case .disconnected:
            onConnect()
        case .online, .connecting:
            onDisconnect()
        }
    }

    func bind() {
        connection.state
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

    func unbind() {
        bag.removeAll()
    }
}
