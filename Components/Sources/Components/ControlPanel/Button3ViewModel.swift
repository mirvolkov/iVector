import SwiftUI

class Button3ViewModel: ControlPanelButtonViewModel {
    @Published var enabled: Bool = true
    @Published var primaryIcon: Image?
    @Published var primaryTitle: String?
    @Published var secondaryTitle: String?
    @Published var tintColor: Color = .green

    init() {
        self.primaryIcon = .init(systemName: "arrow.up.right.square")
        self.primaryTitle = "3"
    }
}
