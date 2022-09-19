import Features
import SwiftUI

class ButtonLiftViewModel: ControlPanelButtonViewModel {
    @Published var enabled: Bool = true
    @Published var primaryIcon: Image?
    @Published var primaryTitle: String?
    @Published var secondaryTitle: String?
    @Published var tintColor: Color = .green

    private let connection: ConnectionModel

    init(connection: ConnectionModel) {
        self.connection = connection
        self.primaryIcon = .init(systemName: "arrowtriangle.up.square.fill") // arrowtriangle.down.square.fill
        self.enabled = false
    }
}
