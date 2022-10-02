import Combine
import Features
import SwiftUI

class ButtonLiftViewModel: ControlPanelButtonViewModel {
    @Published var disableSecondary: Bool = false
    @Published var disableTitle: Bool = false
    @Published var disableIcon: Bool = false
    @Published var enabled: Bool = true
    @Published var primaryIcon: Image?
    @Published var primaryTitle: String?
    @Published var secondaryTitle: String?
    @Published var tintColor: Color = .green
    @Published var isLifted: Bool = false {
        didSet {
            if isLifted {
                self.primaryIcon = .init(systemName: "arrowtriangle.down")
            } else {
                self.primaryIcon = .init(systemName: "arrowtriangle.up")
            }
        }
    }

    private let connection: ConnectionModel
    private var bag = Set<AnyCancellable>()
    private static let minHeight: Float = 32.0
    private static let maxHeight: Float = 92.0

    init(connection: ConnectionModel) {
        self.connection = connection
        self.primaryIcon = .init(systemName: "arrowtriangle.up")
        self.tintColor = .white
    }

    func bind() {
        Task {
            await connection
                .robotState
                .receive(on: RunLoop.main)
                .sink { state in
                    if state.liftHeightMm > (Self.maxHeight - Self.minHeight) {
                        self.isLifted = true
                    } else {
                        self.isLifted = false
                    }
                }
                .store(in: &self.bag)
        }
    }

    func onClick() {
        Task {
            try await connection.behavior?.lift(isLifted ? 0 : 1)
        }
    }
}
