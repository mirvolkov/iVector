import Combine
import Connection
import Features
import SwiftUI

class ButtonDockViewModel: ControlPanelButtonViewModel {
    @Published var enabled: Bool = true
    @Published var primaryIcon: Image?
    @Published var primaryTitle: String?
    @Published var secondaryTitle: String?
    @Published var tintColor: Color = .green

    private let connection: ConnectionModel
    private var bag = Set<AnyCancellable>()
    private var battery: VectorBatteryState? {
        didSet {
            switch battery {
            case .charging, .full:
                primaryIcon = Image(systemName: "square.and.arrow.up")
            default:
                primaryIcon = Image(systemName: "square.and.arrow.down")
            }
        }
    }

    init(connection: ConnectionModel) {
        self.connection = connection
        self.primaryIcon = .init(systemName: "square.and.arrow.down")
        self.tintColor = .red
    }

    func bind() {
        Task {
            await connection.battery
                .subscribe(on: RunLoop.main)
                .compactMap { $0 }
                .assign(to: \.battery, on: self)
                .store(in: &bag)
        }
    }

    func unbind() {
        bag.removeAll()
    }

    func onClick() {
        Task {
            guard let battery = battery else {
                return
            }

            switch battery {
            case .full, .charging:
                try await connection.undock()
            case .normal, .low:
                try await connection.dock()
            default:
                break
            }
        }
    }
}
