import SwiftUI

extension ControlPanelButtonView {
    class Button3ViewModel: ViewModel {
        override init() {
            super.init()
            self.primaryIcon = .init(systemName: "arrow.up.right.square")
            self.primaryTitle = "3"
        }
    }
}
