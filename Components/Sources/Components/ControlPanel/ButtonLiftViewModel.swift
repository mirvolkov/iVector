import Combine
import Features
import Programmator
import SwiftUI

class ButtonLiftViewModel: ControlPanelButtonViewModel {
    @Published var disableSecondary: Bool = false
    @Published var disableTitle: Bool = false
    @Published var disableIcon: Bool = false
    @Published var enabled: Bool = true
    @Published var primaryIcon: Image?
    @Published var primaryTitle: String?
    @Published var secondaryTitle: String?
    @Published var tintColor: Color = .green
    @Published var tag: CPViewModelTag?
    @Published var borderColor: Color?

    private var isPressed = false {
        didSet {
            tag = isPressed ? Instruction.lift(true) : Instruction.lift(false)
            primaryIcon = .init(systemName: isPressed ? "arrowtriangle.up" : "arrowtriangle.down")
        }
    }

    init() {
        defer { self.isPressed = false }
        self.tintColor = .white
        self.borderColor = .black
    }

    func onClick() {
        isPressed.toggle()
    }
}
