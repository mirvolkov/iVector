import Combine
import Features
import SwiftUI

class ButtonLoadViewModel: ControlPanelButtonViewModel {
    @Published var disableSecondary: Bool = false
    @Published var disableTitle: Bool = false
    @Published var disableIcon: Bool = false
    @Published var enabled: Bool = true
    @Published var primaryIcon: Image?
    @Published var primaryTitle: String?
    @Published var secondaryTitle: String?
    @Published var tintColor: Color = .green

    init() {
        self.primaryIcon = .init(systemName: "icloud.and.arrow.down")
        self.tintColor = .purple
    }

    func bind() {
    }

    func onClick() {
    }
}
