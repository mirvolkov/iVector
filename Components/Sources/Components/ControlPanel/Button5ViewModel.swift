import SwiftUI

class Button5ViewModel: ControlPanelButtonViewModel {
    @Published var enabled: Bool = true
    @Published var primaryIcon: Image?
    @Published var primaryTitle: String?
    @Published var secondaryTitle: String?
    @Published var tintColor: Color = .green
    
    init() {
        self.primaryIcon = .init(systemName: "arrow.clockwise")
        self.secondaryTitle = "="
        self.primaryTitle = "5"
    }
}
