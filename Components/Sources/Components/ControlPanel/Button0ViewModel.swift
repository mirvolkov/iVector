import SwiftUI

extension ControlButtonView {
    class Button0ViewModel: ControlButtonViewModel {
        override init() {
            super.init()
            self.primaryIcon = .init(systemName: "arrow.up.backward.square")
            self.primaryTitle = "0"
        }
    }
}
