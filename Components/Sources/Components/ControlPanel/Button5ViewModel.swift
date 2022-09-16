import SwiftUI

extension ControlPanelButtonView {
    class Button5ViewModel: ViewModel {
        override init() {
            super.init()
            self.primaryIcon = .init(systemName: "arrow.up.backward.square")
            self.primaryTitle = "5"
        }
    }
}
