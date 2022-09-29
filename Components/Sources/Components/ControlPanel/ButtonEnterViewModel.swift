import Combine
import Connection
import Features
import SwiftUI

class ButtonEnterViewModel: ControlPanelButtonViewModel {
    @Published var enabled: Bool = true
    @Published var primaryIcon: Image?
    @Published var primaryTitle: String?
    @Published var secondaryTitle: String?
    @Published var tintColor: Color = .green
    @Published var onEnter: Bool = false

    init() {
        self.primaryIcon = .init(systemName: "pip.enter")
        self.primaryTitle = "Ent"
    }

    func onClick() {
        onEnter = true
    }
}
