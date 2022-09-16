import SwiftUI

extension ControlButtonView {
    class Button6ViewModel: ControlButtonViewModel {
        override init() {
            super.init()
            self.primaryIcon = .init(systemName: "arrow.up.backward.square")
            self.primaryTitle = "6"
        }
    }
}
