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
    func motionRecognitionStart()
    func motionRecognitionStop()
    func motionLoggingStart()
    func motionLoggingStop()
}

public enum Motion {
    public struct MotionHeading: SocketConnection.SocketMessage {
        public let heading: Double
        public let date: Date = .init()

        fileprivate init(_ heading: Double) {
            self.heading = heading
        }

        public func socketRepresentation() throws -> SocketData {
            ["heading": heading, "timestamp": date.timeIntervalSince1970]
        }
    }

    // swiftlint:disable identifier_name
    public struct MotionGyro: SocketConnection.SocketMessage {
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

    public struct MotionLabel: SocketConnection.SocketMessage {
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
    private let socket: SocketConnection
    private var isLogging: Bool = false
    private let logger = Logger(subsystem: "com.mirfirstsnow.ivector", category: "main")
    private let detector = MotionDetector()

    public var online: Bool { motionManager.isDeviceMotionActive }

    public init(connection: ConnectionModel) {
        self.socket = connection.socket
    }

    public func start() {
        queue.maxConcurrentOperationCount = 1

        guard !online else {
            return
        }

        motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: self.queue) { [weak self] data, error in
            guard let data = data, let self else {
                return
            }

            if let error {
                logger.error("Motion update \(error)")
                return
            }

            socket.send(Motion.MotionHeading(data.heading), with: "heading")
            detector.pushAccelerometer(data.userAcceleration)
            detector.pushHeading(data.heading)
            detector.step()

            socket.send(Motion.MotionGyro(data.userAcceleration), with: "axelerometer", cachePolicy: .window(100))
            socket.send(Motion.MotionHeading(data.heading), with: "heading", cachePolicy: .window(100))
        }

        detector.callback = { [weak self] label in
            self?.socket.send(label, with: "motionPattern")
        }
    }

    public func stop() {
        defer { detector.motionRecognitionStop() }

        guard online else {
            return
        }

        motionManager.stopDeviceMotionUpdates()
    }

    public func motionLoggingStart() {
        isLogging = true
    }

    public func motionLoggingStop() {
        isLogging = false
    }

    public func motionRecognitionStart() {
        detector.motionRecognitionStart()
    }

    public func motionRecognitionStop() {
        detector.motionRecognitionStop()
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
