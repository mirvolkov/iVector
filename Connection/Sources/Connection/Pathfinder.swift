import AVFoundation
import BLE
import Combine
import CoreImage
import CoreMotion
import OSLog

public struct PFSonar {
    public var sonar1: UInt
    public var sonar2: UInt
    public var sonar3: UInt
    public var sonar4: UInt

    public static var zero: Self { .init(sonar1: 0, sonar2: 0, sonar3: 0, sonar4: 0) }
}

public enum PathfinderError: Error {
    case notConnected
    case cameraFailed
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

let uuidLaser = "6E400003-B5A3-F393-E0A9-E50E24DCCA03" // Laser
let uuidLight = "6E400003-B5A3-F393-E0A9-E50E24DCCA02" // Light
let uuidEngineLF = "6E400003-B5A3-F393-E0A9-E50E24DCCA09" // engine left forward
let uuidEngineRF = "6E400003-B5A3-F393-E0A9-E50E24DCCA0A" // engine right forward
let uuidEngineLB = "6E400003-B5A3-F393-E0A9-E50E24DCCA0B" // engine left backward
let uuidEngineRB = "6E400003-B5A3-F393-E0A9-E50E24DCCA0C" // engine right backward
let uuidSonar0 = "6E400003-B5A3-F393-E0A9-E50E24DCCA04" // sonar 1
let uuidSonar1 = "6E400003-B5A3-F393-E0A9-E50E24DCCA05" // sonar 2
let uuidSonar2 = "6E400003-B5A3-F393-E0A9-E50E24DCCA06" // sonar 3
let uuidSonar3 = "6E400003-B5A3-F393-E0A9-E50E24DCCA07" // sonar 4
let uuidBattery = "6E400003-B5A3-F393-E0A9-E50E24DCCA08" // battery

public final class PathfinderConnection: NSObject, Pathfinder {
    let logger = Logger(subsystem: "com.mirfirstsnow.ivector", category: "pathfinder")
    let captureSession = AVCaptureSession()
    let queue = DispatchQueue(label: "pathfinder.camera")
    let ble: BLE
#if os(iOS)
    let coreMotion = CMMotionManager()
#endif

    var bag = Set<AnyCancellable>()
    var onlineContinuation: CheckedContinuation<Void, Error>?
    var cameraFeedContinuation: AsyncStream<VectorCameraFrame>.Continuation?

    public var online: CurrentValueSubject<Bool, Never> = .init(false)
    public var sonar: PassthroughSubject<PFSonar, Never> = .init()
    public var battery: PassthroughSubject<Int, Never> = .init()

    public init(with bleID: String) {
        ble = BLE([bleID])
        super.init()

        ble.$isOnline.sink { [weak self] online in
            self?.online.value = online
            if online {
                self?.listenSensors()
            }
            if let continuation = self?.onlineContinuation, online {
                continuation.resume()
            }
        }.store(in: &bag)
    }

    public func connect() async throws {
        ble.scan()

        guard !online.value else {
            return
        }

        try await withCheckedThrowingContinuation { continuation in
            self.onlineContinuation = continuation
        }
    }

    public func disconnect() {
        online.value = false
        captureSession.stopRunning()
        onlineContinuation = nil
    }
}
