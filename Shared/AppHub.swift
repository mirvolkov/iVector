import Combine
import Connection
import Features
import SocketIO
import SwiftBus

/**
 Idea of this class is to gather all the data from entire app and perform it postprocessing in ONE place
 */
final class AppHub {
    let connection: ConnectionModel
    var bag: Set<AnyCancellable> = .init()

    init(connection: ConnectionModel) {
        self.connection = connection
    }
 
    func bind() {
        connection.socket.listen("stt") { (stt: AudioFeature.STTData) in
            print(stt)
        }

        connection.socket.listen("acceleration") { (acceleration: Motion.MotionLabel) in
            print(acceleration)
        }

        connection.socket.listen("heading") { (heading: Motion.MotionHeading) in
            print(heading)
        }

        connection.socket.listen("vision") { (vision: VisionFeature.VisionObservation) in
            print(vision)
        }

        connection.socket.listen("sonar") { (sonar: PFSonar) in
            print("sonar \(sonar)")
        }

        connection.socket.listen("proximity") { (sonar: PFSonar) in
            print("proximity \(sonar)")
        }
    }
}
