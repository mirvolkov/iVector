import Combine
import Connection
import Features
import SwiftUI

class ButtonPauseViewModel: ControlPanelButtonViewModel {
    @Published var disableSecondary: Bool = false
    @Published var disableTitle: Bool = false
    @Published var disableIcon: Bool = false
    @Published var enabled: Bool = true
    @Published var primaryIcon: Image?
    @Published var primaryTitle: String?
    @Published var secondaryTitle: String?
    @Published var tintColor: Color = .red
    @Published var tag: CPViewModelTag? {
        didSet {
            enabled = tag != nil
        }
    }

    init() {
        self.primaryIcon = .init(systemName: "exclamationmark.octagon.fill")
        self.tintColor = .red
    }
}
