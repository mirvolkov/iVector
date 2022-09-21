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
        self.primaryIcon = .init(systemName: "square.and.arrow.down")
    }
    
    func bind() {
        Task {
            if try await connection.battery == .charging {
                self.primaryIcon = .init(systemName: "square.and.arrow.up")
            } else {
                self.primaryIcon = .init(systemName: "square.and.arrow.down")
            }
        }
    }
    
    func onClick() {
        Task {
            print(await try connection.battery)
            if try await connection.battery == .charging {
                try await connection.undock()
            } else {
                try await connection.dock()
            }
        }
    }
}
