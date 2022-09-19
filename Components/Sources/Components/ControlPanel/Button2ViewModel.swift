import SwiftUI

class Button2ViewModel: ControlPanelButtonViewModel {
    @Published var enabled: Bool = true
    @Published var primaryIcon: Image?
    @Published var primaryTitle: String?
    @Published var secondaryTitle: String?
    @Published var tintColor: Color = .green
    
    init() {
        self.primaryIcon = .init(systemName: "arrow.up.square")
        self.primaryTitle = "2"
    }
}