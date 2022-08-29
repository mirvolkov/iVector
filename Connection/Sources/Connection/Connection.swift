import GRPC

public protocol Connection {
    func control() throws -> ControlRequestStream 
}

public protocol ConnectionDelegate: AnyObject {
    func didGrantedControl()
    func didFailedRequest()
    func keepAlive()
    func didClose()
}

public enum ConnectionError: Error {
    case notConnected
}
