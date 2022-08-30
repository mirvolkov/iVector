import GRPC

// Control request stream typealias
public typealias ControlRequestStream = BidirectionalStreamingCall<Anki_Vector_ExternalInterface_BehaviorControlRequest, Anki_Vector_ExternalInterface_BehaviorControlResponse>

/// Anki Vector's connection protocol
public protocol Connection {
    /// Connection delegate
    var delegate: ConnectionDelegate? { get set }
    
    /// Request control stream
    /// - Throws error of control request failed
    func requestControl() throws
}

/// Connection delegate to handle stream events
public protocol ConnectionDelegate: AnyObject {
    func didGrantedControl()
    func didFailedRequest()
    func keepAlive()
    func didClose()
}

public enum ConnectionError: Error {
    case notConnected
}
