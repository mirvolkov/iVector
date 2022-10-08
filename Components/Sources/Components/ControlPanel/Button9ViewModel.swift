import SwiftUI

class Button9ViewModel: ControlPanelButtonViewModel {
    @Published var disableSecondary: Bool = false
    @Published var disableTitle: Bool = false
    @Published var disableIcon: Bool = false
    @Published var enabled: Bool = true
    @Published var primaryIcon: Image?
    @Published var primaryTitle: String?
    @Published var secondaryTitle: String?
    @Published var tintColor: Color = .green
    @Published var tag: CPViewModelTag? {
        didSet {
            enabled = tag != nil
        }
    }

    init() {
        self.primaryIcon = .init(systemName: "arrow.down.right.square")
        self.primaryTitle = "9"
        self.secondaryTitle = "listen"
    }
}
