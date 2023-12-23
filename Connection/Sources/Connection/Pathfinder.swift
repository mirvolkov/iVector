import AVFoundation
import BLE
import Combine
import CoreImage
import OSLog

public struct PFSonar {
    public var sonar0: UInt
    public var sonar1: UInt
    public var sonar2: UInt
    public var sonar3: UInt
    public let date = Date()

    public static var zero: Self { .init((0, 0, 0, 0)) }

    public init(_ sonars: (UInt, UInt, UInt, UInt)) {
        self.sonar0 = sonars.0
        self.sonar1 = sonars.1
        self.sonar2 = sonars.2
        self.sonar3 = sonars.3
    }
}

public enum PathfinderError: Error {
    case notConnected
    case cameraFailed
    case micFailed
    case speakerFailed
}

/**
 Pathfinder connection protocol
 Camera, gyroscope and mic are - build-in
 Sonar and other peripherals connected to pathfinder through BLE
 */
public protocol Pathfinder {
    var online: CurrentValueSubject<Bool, Never> { get }

    func connect() async throws
    func disconnect()
}

public final class PathfinderConnection: NSObject, Pathfinder {
    enum Const {
        static let uuidLaser = "6E400003-B5A3-F393-E0A9-E50E24DCCA03" // Laser
        static let uuidLight = "6E400003-B5A3-F393-E0A9-E50E24DCCA02" // Light
        static let uuidEngineLF = "6E400003-B5A3-F393-E0A9-E50E24DCCA09" // engine left forward
        static let uuidEngineRF = "6E400003-B5A3-F393-E0A9-E50E24DCCA0A" // engine right forward
        static let uuidEngineLB = "6E400003-B5A3-F393-E0A9-E50E24DCCA0B" // engine left backward
        static let uuidEngineRB = "6E400003-B5A3-F393-E0A9-E50E24DCCA0C" // engine right backward
        static let uuidSonar0 = "6E400003-B5A3-F393-E0A9-E50E24DCCA04" // sonar 1
        static let uuidSonar1 = "6E400003-B5A3-F393-E0A9-E50E24DCCA05" // sonar 2
        static let uuidSonar2 = "6E400003-B5A3-F393-E0A9-E50E24DCCA06" // sonar 3
        static let uuidSonar3 = "6E400003-B5A3-F393-E0A9-E50E24DCCA07" // sonar 4
        static let uuidBattery = "6E400003-B5A3-F393-E0A9-E50E24DCCA08" // battery
        static let uuidHeadAngle = "6E400003-B5A3-F393-E0A9-E50E24DCCA0E" // battery
        static let uuidPower = "6E400003-B5A3-F393-E0A9-E50E24DCCA0F" // power relay
        static let uuidProximity = "6E400003-B5A3-F393-E0A9-E50E24DCCA0D" // proximity sensor
    }

    let logger = Logger(subsystem: "com.mirfirstsnow.ivector", category: "pathfinder")
    lazy var captureSession = AVCaptureSession()
    let queue = DispatchQueue(label: "pathfinder.camera")
    let ble: BLE
    var bag = Set<AnyCancellable>()
    var onlineContinuation: UnsafeContinuation<Void, Error>?
    var cameraInitContinuation: UnsafeContinuation<AsyncStream<VectorCameraFrame>, Never>?
    var cameraFeedContinuation: AsyncStream<VectorCameraFrame>.Continuation?
    var cameraSettings: VectorCameraSettings?
    
    public var online: CurrentValueSubject<Bool, Never> = .init(false)
    public var sonar: PassthroughSubject<PFSonar, Never> = .init()
    public var battery: PassthroughSubject<UInt, Never> = .init()
    public var headAngle: PassthroughSubject<Float, Never> = .init()
    public var power: PassthroughSubject<Bool, Never> = .init()
    public var proximity: PassthroughSubject<UInt, Never> = .init()

    public init(with bleID: String) {
        ble = BLE([bleID])
        super.init()
    }

    deinit {
        print("PF deinit")
    }

    public func connect() async throws {
        guard !online.value else {
            return
        }

        try await withUnsafeThrowingContinuation { continuation in
            onlineContinuation = continuation
            ble.scan()
            ble.$isOnline
                .sink { [weak self] online in
                    self?.online.value = online
                    if online {
                        self?.listenSensors()
                        self?.onlineContinuation?.resume()
                        self?.onlineContinuation = nil
                    }
                }.store(in: &bag)
        }
    }

    public func disconnect() {
        online.value = false
        bag.removeAll()
        ble.disconnect()
        captureSession.stopRunning()
    }
}
