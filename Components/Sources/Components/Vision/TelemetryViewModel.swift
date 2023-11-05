import Combine
import Features
import Observation

@Observable class TelemetryViewModel: ObservableObject {
    var battery: String?
    var stt: String?
    var heading: Double?
    var sonars: [UInt]?
    var motionLabel: String?
    var observations: [String] = []

    @ObservationIgnored
    private var bag = Set<AnyCancellable>()

    init(with connection: ConnectionModel) {
        Task { @MainActor [self] in
            while let battery = try await connection.battery {
                self.battery = battery.description
                try await Task.sleep(for: .seconds(1))
            }
        }

        connection.socket.listen { (data: AudioFeature.STTData) in
            self.stt = data.text
        }

        connection.socket.listen { (data: MotionLabel) in
            self.motionLabel = data.label
        }

        connection.socket.listen { (data: MotionHeading) in
            self.heading = data.heading
        }

        connection.socket.listen { (data: VisionFeature.VisionObservation) in
            self.observations.append(data.label)
            if self.observations.count > 2 {
                self.observations.removeFirst()
            }
        }

        connection.vectorState.sink { state in
            self.sonars = [UInt(state.proxData.distanceMm)]
        }.store(in: &bag)

        connection.pathfinder?.sonar.sink(receiveValue: { state in
            self.sonars = [state.sonar0, state.sonar1, state.sonar2, state.sonar3]
        }).store(in: &bag)
    }
}
