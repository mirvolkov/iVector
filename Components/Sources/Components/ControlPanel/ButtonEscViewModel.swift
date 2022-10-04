import Combine
import Connection
import Features
import SwiftUI

class ButtonEscViewModel: ControlPanelButtonViewModel {
    @Published var disableSecondary: Bool = false
    @Published var disableTitle: Bool = false
    @Published var disableIcon: Bool = false
    @Published var enabled: Bool = true
    @Published var primaryIcon: Image?
    @Published var primaryTitle: String?
    @Published var secondaryTitle: String?
    @Published var tintColor: Color = .green
    @Published var onEsc: Bool = false
    @Published var tag: CPViewModelTag?

    init() {
        self.primaryIcon = .init(systemName: "delete.backward")
        self.primaryTitle = "Esc"
    }

    func onClick() {
        onEsc = true
    }
}
