import Connection
import SocketIO

extension PFSonar: AppHub.SocketMessage {
    public func socketRepresentation() throws -> SocketData {
        ["0": sonar0, "1": sonar1, "2": sonar2, "3": sonar3, "timestamp": date.timeIntervalSince1970]
    }
}
