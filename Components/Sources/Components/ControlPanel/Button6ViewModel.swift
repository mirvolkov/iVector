import SwiftUI

extension ControlPanelButtonView {
    class Button6ViewModel: ViewModel {
        override init() {
            super.init()
            self.primaryIcon = .init(systemName: "arrow.up.backward.square")
            self.primaryTitle = "6"
        }
    }
}
