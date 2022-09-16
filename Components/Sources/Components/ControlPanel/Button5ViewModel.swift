import SwiftUI

extension ControlButtonView {
    class Button5ViewModel: ControlButtonViewModel {
        override init() {
            super.init()
            self.primaryIcon = .init(systemName: "arrow.up.backward.square")
            self.primaryTitle = "5"
        }
    }
}
