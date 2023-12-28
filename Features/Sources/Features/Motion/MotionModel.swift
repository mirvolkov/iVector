import Combine
import Connection
import CoreML
import CoreMotion
import Foundation
import OSLog
import SocketIO
import SwiftBus

public protocol MotionModel: Sendable {
    init(connection: ConnectionModel)
    func start()
    func stop()
}

public enum Motion {
    public struct MotionHeading: AppHub.SocketMessage {
        public let value: Double
        public let date: Date = .init()

        fileprivate init(_ heading: Double) {
            self.value = heading
        }

        public func socketRepresentation() throws -> SocketData {
            ["heading": value, "timestamp": date.timeIntervalSince1970]
        }
    }

    // swiftlint:disable identifier_name
    public struct MotionGyro: AppHub.SocketMessage {
        public let x: Double
        public let y: Double
        public let z: Double
        public let date: Date = .init()

        public func socketRepresentation() throws -> SocketData {
            ["x": x, "y": y, "z": z, "timestamp": date.timeIntervalSince1970]
        }

        fileprivate init(_ value: CMAcceleration) {
            x = value.x
            y = value.y
            z = value.z
        }
    }

    public struct MotionLabel: AppHub.SocketMessage {
        public let label: String
        public let date: Date = .init()

        public func socketRepresentation() throws -> SocketData {
            ["label": label, "timestamp": date.timeIntervalSince1970]
        }
    }
}

// swiftlint:enable identifier_name

#if os(iOS)
public final class MotionModelImpl: @unchecked Sendable, MotionModel {
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    private let hub: AppHub
    private let logger = Logger(subsystem: "com.mirfirstsnow.ivector", category: "main")

    public var online: Bool { motionManager.isDeviceMotionActive }

    public init(connection: ConnectionModel) {
        self.hub = connection.hub
    }

    public func start() {
        queue.maxConcurrentOperationCount = 1

        guard !online else {
            return
        }

        motionManager.startDeviceMotionUpdates(
            using: .xMagneticNorthZVertical,
            to: self.queue
        ) { [weak self] data, error in
            guard let data = data, let self else {
                return
            }

            if let error {
                logger.error("Motion update \(error)")
                return
            }

            hub.send(Motion.MotionGyro(data.userAcceleration), with: "acceleration", cachePolicy: .window(100))
            hub.send(Motion.MotionHeading(data.heading), with: "heading", cachePolicy: .window(100))
        }
    }

    public func stop() {
        guard online else {
            return
        }

        motionManager.stopDeviceMotionUpdates()
    }
}

#else
public final class MotionModelImpl: MotionModel {
    public init(connection: ConnectionModel) {}
    public func start() {}
    public func stop() {}
    public func motionRecognitionStart() {}
    public func motionRecognitionStop() {}
    public func motionLoggingStart() {}
    public func motionLoggingStop() {}
}
#endif
