import Features
import SwiftUI

class ButtonDockViewModel: ControlPanelButtonViewModel {
    @Published var isLoading: Bool = false
    @Published var enabled: Bool = true
    @Published var primaryIcon: Image?
    @Published var primaryTitle: String?
    @Published var secondaryTitle: String?
    @Published var tintColor: Color = .green
    private let connection: ConnectionModel

    init(connection: ConnectionModel) {
        self.connection = connection
        self.primaryIcon = .init(systemName: "square.and.arrow.down") // square.and.arrow.up
//        self.enabled = false
    }
    
    func onClick() {
        Task {
            try await connection.dock()
        }
    }
}
