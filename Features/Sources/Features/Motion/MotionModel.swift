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
    public struct MotionHeading: EventRepresentable {
        public let heading: Double
    }

    // swiftlint:disable identifier_name
    public struct MotionGyro: EventRepresentable {
        public let x: Double
        public let y: Double
        public let z: Double
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
    private let detector: MotionDetector

    public var online: Bool { motionManager.isDeviceMotionActive }

    public init(connection: ConnectionModel) {
        self.socket = connection.socket
        self.detector = MotionDetector(with: connection.socket)
    }

    public func start() {
        queue.maxConcurrentOperationCount = 1

        guard !online else {
            return
        }

        motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: self.queue) { [self] data, error in
            guard let data = data else {
                return
            }

            if let error {
                logger.error("Motion update \(error)")
                return
            }

            socket.send(event: Motion.MotionHeading(heading: data.heading))
            socket.send(event: Motion.MotionGyro(x: data.gravity.x, y: data.gravity.y, z: data.gravity.z))
            detector.pushAccelerometer(data.userAcceleration)
            detector.pushRotation(data.rotationRate)
            detector.pushHeading(data.heading)
            detector.step()

            socket.send(message: [
                "x": data.gravity.x,
                "y": data.gravity.y,
                "z": data.gravity.z,
                "datetime": Date().timeIntervalSince1970
            ], with: "axelerometer", cachePolicy: .window(100))
            socket.send(message: [
                "x": data.rotationRate.x,
                "y": data.rotationRate.y,
                "z": data.rotationRate.z,
                "datetime": Date().timeIntervalSince1970
            ], with: "gyroscope", cachePolicy: .window(100))
            socket.send(message: [
                "heading": data.heading,
                "datetime": Date().timeIntervalSince1970
            ], with: "heading", cachePolicy: .window(100))
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
