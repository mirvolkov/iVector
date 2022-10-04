import Combine
import Connection
import Features
import SwiftUI

class ButtonEnterViewModel: ControlPanelButtonViewModel {
    @Published var disableSecondary: Bool = false
    @Published var disableTitle: Bool = false
    @Published var disableIcon: Bool = false
    @Published var enabled: Bool = true
    @Published var primaryIcon: Image?
    @Published var primaryTitle: String?
    @Published var secondaryTitle: String?
    @Published var tintColor: Color = .green
    @Published var onEnter: Bool = false
    @Published var tag: CPViewModelTag?

    init() {
        self.primaryIcon = .init(systemName: "pip.enter")
        self.primaryTitle = "Ent"
    }

    func onClick() {
        onEnter = true
    }
}
