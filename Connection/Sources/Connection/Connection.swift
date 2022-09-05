import GRPC

// Control request stream typealias
public typealias ControlRequestStream = BidirectionalStreamingCall<Anki_Vector_ExternalInterface_BehaviorControlRequest,
    Anki_Vector_ExternalInterface_BehaviorControlResponse>

/// Anki Vector's connection protocol
public protocol Connection {
    /// Connection delegate
    var delegate: ConnectionDelegate? { get set }

    /// Request control
    /// - Throws error of control request failed
    func requestControl() throws

    /// Release control
    /// - Throws if release request is failed
    func releaseControl() throws

    /// Initialise SDK
    /// - Throws if sdk init falied
    func initSdk() async throws
    
    
    /// Request event stream
    /// - Throws if request failed
    func eventStream() throws -> AsyncStream<Anki_Vector_ExternalInterface_RobotState>? 
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
