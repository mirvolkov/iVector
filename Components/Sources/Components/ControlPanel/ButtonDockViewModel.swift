import SwiftUI
import Features

extension ControlPanelButtonView {
    class ButtonDockViewModel: ControlPanelButtonView.ViewModel {
        private let connection: ConnectionModel
        
        init(connection: ConnectionModel) {
            self.connection = connection
            super.init()
            self.primaryIcon = .init(systemName: "square.and.arrow.down") //square.and.arrow.up
            self.enabled = false
        }
    }
}
