import SwiftUI

extension ControlButtonView {
    class Button8ViewModel: ControlButtonViewModel {
        override init() {
            super.init()
            self.primaryIcon = .init(systemName: "arrow.up.backward.square")
            self.primaryTitle = "8"
        }
    }
}
