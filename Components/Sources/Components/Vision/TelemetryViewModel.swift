import Combine
import Features
import Observation

public extension TelemetryView {
    @Observable final class ViewModel: ObservableObject {
        var battery: String?
        var stt: String?
        var heading: Double?
        var sonars: [UInt]?
        var motionLabel: String?
        var observations: [String] = []

        @ObservationIgnored
        private var bag = Set<AnyCancellable>()

        public init(with connection: ConnectionModel) {
            Task { @MainActor [self] in
                while let battery = try await connection.battery {
                    self.battery = battery.description
                    try await Task.sleep(for: .seconds(1))
                }
            }

            connection.socket.listen("stt") { (data: AudioFeature.STTData) in
                self.stt = data.text
            }

            connection.socket.listen("acceleratin") { (data: Motion.MotionLabel) in
                self.motionLabel = data.label
            }

            connection.socket.listen("heading") { (data: Motion.MotionHeading) in
                self.heading = data.value
            }

            connection.socket.listen("vision") { (data: VisionFeature.VisionObservation) in
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

            connection.pathfinder?.proximity.sink(receiveValue: { state in
                self.sonars?.append(state)
            }).store(in: &bag)
        }
    }
}
