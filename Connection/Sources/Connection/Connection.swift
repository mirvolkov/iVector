import GRPC

// Control request stream typealias
public typealias ControlRequestStream = BidirectionalStreamingCall<Anki_Vector_ExternalInterface_BehaviorControlRequest,
    Anki_Vector_ExternalInterface_BehaviorControlResponse>

// Event stream typealias
public typealias EventStream =
    BidirectionalStreamingCall<Anki_Vector_ExternalInterface_EventRequest,
        Anki_Vector_ExternalInterface_EventResponse>

/// Anki Vector's connection protocol
public protocol Connection {
    /// Connection delegate
    var delegate: ConnectionDelegate? { get set }

    /// Request control
    /// - Throws error of control request failed
    func requestControl() throws

    /// Release control
    /// - Throws if release request is failed
    func release() throws

    /// Initialise SDK
    /// - Throws if sdk init falied
    func initSdk() async throws

    /// Request event stream
    /// - Throws if request failed
    func requestEventStream() throws
}

/// Connection delegate to handle stream events
public protocol ConnectionDelegate: AnyObject {
    func didGrantedControl()
    func didFailedRequest()
    func keepAlive()
    func didClose()
    func onRobot(state: Anki_Vector_ExternalInterface_RobotState)
}

public enum ConnectionError: Error {
    case notConnected
}
