import SwiftUI
import Features

extension ControlPanelButtonView {
    class ButtonLiftViewModel: ControlPanelButtonView.ViewModel {
        private let connection: ConnectionModel
        
        init(connection: ConnectionModel) {
            self.connection = connection
            super.init()
            self.primaryIcon = .init(systemName: "arrowtriangle.up.square.fill") //arrowtriangle.down.square.fill
            self.enabled = false
        }
    }
}
