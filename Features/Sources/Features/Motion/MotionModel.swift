import Combine
import Connection
import CoreML
import CoreMotion
import Foundation
import OSLog
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

public struct MotionHeading: EventRepresentable {
    public let heading: Double
}

// swiftlint:disable identifier_name
public struct MotionGyro: EventRepresentable {
    public let x: Double
    public let y: Double
    public let z: Double
}

// swiftlint:enable identifier_name

#if os(iOS)
public final class MotionModelImpl: @unchecked Sendable, MotionModel {
    private let motionManager = CMMotionManager()

    private let queue = OperationQueue()
    private let connection: ConnectionModel
    private var socket: SocketConnection? { connection.socket }
    private var isLogging: Bool = false
    private let logger = Logger(subsystem: "com.mirfirstsnow.ivector", category: "main")
    private let detector = MotionDetector()

    public var online: Bool { motionManager.isDeviceMotionActive }

    public init(connection: ConnectionModel) {
        self.connection = connection
    }

    public func start() {
        queue.maxConcurrentOperationCount = 1

        guard !online, EnvironmentDevice.isSimulator else {
            return
        }

        motionManager.startDeviceMotionUpdates(to: self.queue) { [self] data, error in
            guard let data = data else {
                return
            }

            if let error {
                logger.error("Motion update \(error)")
                return
            }

            self.socket?.send(event: MotionHeading(heading: data.heading))
            self.socket?.send(event: MotionGyro(x: data.gravity.x, y: data.gravity.y, z: data.gravity.z))
            self.detector.pushAccelerometer(data.userAcceleration)
            self.detector.pushRotation(data.rotationRate)
            self.detector.pushHeading(data.heading)
            self.detector.step()
            if isLogging { log() }
        }

        detector.onRecognize = { label in
            self.socket?.send(event: label)
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

extension MotionModelImpl {
    func log() {
        Task {
            try await socket?.send(
                messages: (0..<99).map { index in [detector.accX[index], detector.accY[index], detector.accZ[index]] },
                with: "axelerometer"
            )
            try await socket?.send(
                messages: (0..<99).map { index in [detector.rotX[index], detector.rotY[index], detector.rotZ[index]] },
                with: "gyroscope"
            )
        }
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
