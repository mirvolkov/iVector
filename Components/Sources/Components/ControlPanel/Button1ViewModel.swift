import SwiftUI

extension ControlButtonView {
    class Button1ViewModel: ControlButtonViewModel {
        override init() {
            super.init()
            self.primaryIcon = .init(systemName: "arrow.up.left.square")
            self.primaryTitle = "1"
        }
    }
}
