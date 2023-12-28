import Combine
import Connection
import Features
import SocketIO
import SwiftBus

extension AppHub {
    func bind() {
        let motionPatternDetector = MotionDetector()
        let visionObjectDetector = VisionObjectDetector()
        var counter = 0

        listen("stt") { (stt: AudioFeature.STTData) in
            print(stt)
        }

        listen("camera") { (frame: VectorCameraFrame) in
            if counter % 10 == 0 {
                visionObjectDetector.process(frame.image)
                counter = 0
            }
            counter += 1
        }

        motionPatternDetector.callback = { [self] label in
            send(label, with: "motionPattern")
            print(label)
        }

        visionObjectDetector
            .objects
            .sink { [self] objects in
                objects.forEach { [self] observation in
                    if let label = observation.labels.max(by: { $0.confidence < $1.confidence }) {
                        send(
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

        listen("acceleration") { [self] (acceleration: Motion.MotionGyro) in
//            motionPatternDetector.pushAccelerometer(.init(x: acceleration.x, y: acceleration.y, z: acceleration.z))
//            motionPatternDetector.step()
//            print(acceleration)
        }

        listen("heading") { (heading: Motion.MotionHeading) in
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
