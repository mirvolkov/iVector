import Combine
import Connection
import Features
import Foundation
import SocketIO
import SwiftBus

extension AppHub {
    func bind() {
        let motionPatternDetector = MotionDetector()
        let visionObjectDetector = VisionObjectDetector()
        var counter = 0
        var speed_sonar: Double = 0
        var speed_accel = 0
        var timespan_sonar: Date = .now
        var timespan_accel: Date = .now
        var last_sonar: PFSonar?

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
            .sink { [weak self] objects in
                objects.forEach { [weak self] observation in
                    self?.send(
                        VisionFeature.VisionObservation(
                            label: observation.labels[0].identifier,
                            confidence: observation.confidence,
                            rect: observation.boundingBox
                        ),
                        with: "vision"
                    )
                }
            }
            .store(in: &bag)

        visionObjectDetector
            .barcodes
            .sink { [self] objects in
                objects.forEach { [self] observation in
                    print("BARCODE: \(observation.payloadStringValue)")
                }
            }
            .store(in: &bag)

        listen("acceleration") { [self] (acceleration: Motion.MotionGyro) in
            motionPatternDetector.pushAccelerometer(.init(x: acceleration.x, y: acceleration.y, z: acceleration.z))
            motionPatternDetector.step()
            speed_accel = speed_accel + Int(acceleration.x * (timespan_accel.timeIntervalSince1970 - Date.now.timeIntervalSince1970))
            timespan_accel = .now
        }

        listen("heading") { (heading: Motion.MotionHeading) in
            print(heading)
        }

        listen("sonar") { (sonar: PFSonar) in
            print("sonar \(sonar)")
            speed_sonar = Double(sonar.sonar1 - (last_sonar?.sonar1 ?? 0)) / Double(timespan_sonar.timeIntervalSince1970 - Date.now.timeIntervalSince1970)
            timespan_sonar = .now
        }

        listen("proximity") { (sonar: PFSonar) in
            print("proximity \(sonar)")
        }
    }
}
