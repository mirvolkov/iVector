import Combine
import Programmator
import Features
import SwiftUI

class ButtonDockViewModel: ControlPanelButtonViewModel {
    @Published var disableSecondary: Bool = false
    @Published var disableTitle: Bool = false
    @Published var disableIcon: Bool = false
    @Published var enabled: Bool = true
    @Published var primaryIcon: Image?
    @Published var primaryTitle: String?
    @Published var secondaryTitle: String?
    @Published var tintColor: Color = .green
    @Published var tag: CPViewModelTag?

    private var isPressed = false {
        didSet {
            tag = isPressed ? Instruction.dock(true) : Instruction.dock(false)
            primaryIcon = .init(systemName: isPressed ? "tray.and.arrow.up" : "tray.and.arrow.down")
        }
    }

    init() {
        defer { self.isPressed = false }
        self.tintColor = .black
    }

    func onClick() {
        isPressed.toggle()
    }
}
