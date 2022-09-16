import SwiftUI

extension ControlPanelButtonView {
    class Button1ViewModel: ViewModel {
        override init() {
            super.init()
            self.primaryIcon = .init(systemName: "arrow.up.left.square")
            self.primaryTitle = "1"
        }
    }
}
