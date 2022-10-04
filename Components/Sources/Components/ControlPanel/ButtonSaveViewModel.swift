import Combine
import Features
import SwiftUI

class ButtonSaveViewModel: ControlPanelButtonViewModel {
    @Published var disableSecondary: Bool = false
    @Published var disableTitle: Bool = false
    @Published var disableIcon: Bool = false
    @Published var enabled: Bool = true
    @Published var primaryIcon: Image?
    @Published var primaryTitle: String?
    @Published var secondaryTitle: String?
    @Published var tintColor: Color = .green
    @Published var tag: CPViewModelTag?

    init() {
        self.primaryIcon = .init(systemName: "externaldrive.badge.plus")
        self.tintColor = .black
        self.primaryTitle = "#0"
        self.enabled = false
    }

    func onClick() {
    }
}