import BLE
import Combine
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
}

/**
 Pathfinder connection protocol
 Camera, gyroscope and mic are - build-in
 Sonar and other peripherals connected to pathfinder through BLE
 */
public protocol Pathfinder {
    var online: Bool { get async throws }
    var sonar: PFSonar { get async throws }
    var current: Int { get async throws }

    func connect() async throws
    func disconnect() async throws
}

public final class PathfinderConnection: Pathfinder {
    private let logger = Logger(subsystem: "com.mirfirstsnow.ivector", category: "pathfinder")
    private let ble = BLE(["PF2"])
    private var bag = Set<AnyCancellable>()
    private var continuation: CheckedContinuation<Void, Error>?

    public var online: Bool = false
    public var sonar: PFSonar = .zero
    public var current: Int = 0

    public init() {
        ble.$isOnline.sink { [weak self] online in
            self?.online = online
            if let continuation = self?.continuation, online {
                continuation.resume()
            }
        }.store(in: &bag)
    }

    public func connect() async throws {
        ble.scan()

        guard !online else { return }

        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
        }
    }

    public func disconnect() async throws {
        online = false
        continuation = nil
    }
}
