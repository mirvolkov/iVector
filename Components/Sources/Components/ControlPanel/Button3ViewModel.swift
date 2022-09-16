import SwiftUI

extension ControlButtonView {
    class Button3ViewModel: ControlButtonViewModel {
        override init() {
            super.init()
            self.primaryIcon = .init(systemName: "arrow.up.right.square")
            self.primaryTitle = "3"
        }
    }
}
