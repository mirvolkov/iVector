import Combine
import Connection
import Features
import SocketIO
import SwiftBus

/**
 Idea of this class is to gather all the data from entire app and perform it postprocessing in ONE place
 */
final class AppHub {
    private let connection: ConnectionModel
    private let motionPatternDetector = MotionDetector()
    private let visionObjectDetector = VisionObjectDetector()
    private var bag: Set<AnyCancellable> = .init()

    init(connection: ConnectionModel) {
        self.connection = connection
    }

    func bind() {
        connection.socket.listen("stt") { (stt: AudioFeature.STTData) in
            print(stt)
        }

        connection.socket.listen("camera") { [weak self] (frame: VectorCameraFrame) in
            self?.visionObjectDetector.process(frame.image)
        }

        motionPatternDetector.callback = { [self] label in
            connection.socket.send(label, with: "motionPattern")
            print(label)
        }

        visionObjectDetector
            .objects
            .sink { [self] objects in
                objects.forEach { [self] observation in
                    if let label = observation.labels.max(by: { $0.confidence < $1.confidence }) {
                        self.connection.socket.send(
                            VisionFeature.VisionObservation(
                                label: label.identifier,
                                confidence: label.confidence
                            ),
                            with: "vision"
                        )
                    }
                }
            }
            .store(in: &bag)

        visionObjectDetector
            .barcodes
            .sink { [self] objects in
                objects.forEach { [self] observation in
                    print(observation.payloadStringValue)
                }
            }
            .store(in: &bag)

        connection.socket.listen("acceleration") { [self] (acceleration: Motion.MotionGyro) in
//            motionPatternDetector.pushAccelerometer(.init(x: acceleration.x, y: acceleration.y, z: acceleration.z))
//            motionPatternDetector.step()
//            print(acceleration)
        }

        connection.socket.listen("heading") { (heading: Motion.MotionHeading) in
//            print(heading)
        }

//        connection.socket.listen("vision") { (vision: VisionFeature.VisionObservation) in
//            print(vision)
//        }
//
//        connection.socket.listen("sonar") { (sonar: PFSonar) in
//            print("sonar \(sonar)")
//        }
//
//        connection.socket.listen("proximity") { (sonar: PFSonar) in
//            print("proximity \(sonar)")
//        }
    }
}
