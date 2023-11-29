import Connection
import Features
import SocketIO
import SwiftBus

/**
 Idea of this class is to gather all the data from entire app and perform it postprocessing in ONE place
 */
final class AppHub {
    let socket: SocketConnection

    init(connection: ConnectionModel) {
        self.socket = connection.socket
    }
}
