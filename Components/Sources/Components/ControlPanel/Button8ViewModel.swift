import SwiftUI

extension ControlPanelButtonView {
    class Button8ViewModel: ViewModel {
        override init() {
            super.init()
            self.primaryIcon = .init(systemName: "arrow.up.backward.square")
            self.primaryTitle = "8"
        }
    }
}
