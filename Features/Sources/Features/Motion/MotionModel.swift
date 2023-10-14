import Combine
import Connection
import CoreML
import CoreMotion
import Foundation

public protocol MotionModel: Sendable {
    init(connection: ConnectionModel)
    func start()
    func stop()
    func motionRecognitionStart()
    func motionRecognitionStop()
    func motionLoggingStart()
    func motionLoggingStop()
}

#if os(iOS)
public final class MotionModelImpl: @unchecked Sendable, MotionModel {
    private static let predictionWindowSize = 100
    private let model = try? collisionDetector.init(configuration: .init())
    private let motionManager = CMMotionManager()
    private var currentState = MotionModelImpl.stateInit()
    private let accX = MotionModelImpl.axelInit()
    private let accY = MotionModelImpl.axelInit()
    private let accZ = MotionModelImpl.axelInit()
    private let rotX = MotionModelImpl.axelInit()
    private let rotY = MotionModelImpl.axelInit()
    private let rotZ = MotionModelImpl.axelInit()
    private let queue = OperationQueue()
    private let connection: ConnectionModel
    private var currentIndexInPredictionWindow = 0
    private var cancellable: AnyCancellable?
    private var socket: SocketConnection? { connection.socket }
    private var isLogging: Bool = false

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
            guard let data = data else { return }
            if let error {
                print(error)
                return
            }

            rotX[currentIndexInPredictionWindow] = data.rotationRate.x as NSNumber
            rotY[currentIndexInPredictionWindow] = data.rotationRate.y as NSNumber
            rotZ[currentIndexInPredictionWindow] = data.rotationRate.z as NSNumber
            accX[currentIndexInPredictionWindow] = data.userAcceleration.x as NSNumber
            accY[currentIndexInPredictionWindow] = data.userAcceleration.y as NSNumber
            accZ[currentIndexInPredictionWindow] = data.userAcceleration.z as NSNumber
            currentIndexInPredictionWindow += 1
            if currentIndexInPredictionWindow == Self.predictionWindowSize - 1 {
                currentIndexInPredictionWindow = 0
                if isLogging { log() }
            }
        }
    }

    public func stop() {
        defer { cancellable?.cancel() }

        guard online else {
            return
        }

        motionManager.stopDeviceMotionUpdates()
    }

    public func motionRecognitionStart() {
        cancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { _ in
                self.recognize()
            })
    }

    public func motionRecognitionStop() {
        cancellable?.cancel()
    }

    public func motionLoggingStart() {
        isLogging = true
    }

    public func motionLoggingStop() {
        isLogging = false
    }
}

extension MotionModelImpl {
    func log() {
        Task {
            try await socket?.send(
                messages: (0..<99).map { index in [accX[index], accY[index], accZ[index]] },
                with: "axelerometer"
            )
            try await socket?.send(
                messages: (0..<99).map { index in [rotX[index], rotY[index], rotZ[index]] },
                with: "gyroscope"
            )
        }
    }

    func recognize() {
        autoreleasepool {
            if let modelPrediction = try? self.model?.prediction(
                x: self.accX,
                y: self.accY,
                z: self.accZ,
                stateIn: self.currentState
            ) {
                self.currentState = modelPrediction.stateOut
                print(modelPrediction.label)
            }
        }
    }
}

extension MotionModelImpl {
    static func stateInit() -> MLMultiArray {
        // swiftlint:disable:next force_try
        try! MLMultiArray(
            shape: [400 as NSNumber],
            dataType: MLMultiArrayDataType.double
        )
    }

    static func axelInit() -> MLMultiArray {
        // swiftlint:disable:next force_try
        try! MLMultiArray(
            shape: [MotionModelImpl.predictionWindowSize] as [NSNumber],
            dataType: MLMultiArrayDataType.double
        )
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
