import SwiftUI

extension ControlButtonView {
    class ConnectViewModel: ControlButtonViewModel {
        override init() {
            super.init()
            self.primaryIcon = .init(systemName: "power")
        }
    }
}
