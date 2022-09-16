import SwiftUI

extension ControlPanelButtonView {
    class Button4ViewModel: ViewModel {
        override init() {
            super.init()
            self.primaryIcon = .init(systemName: "arrow.up.backward.square")
            self.primaryTitle = "4"
        }
    }
}
