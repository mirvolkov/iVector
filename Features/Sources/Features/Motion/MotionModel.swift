import Combine
import Connection
import CoreML
import CoreMotion
import Foundation

public protocol MotionModel: Sendable {
    init()
    func start(connection: ConnectionModel)
    func stop()
}

#if os(iOS)
public final class MotionModelImpl: @unchecked Sendable, MotionModel {
    public typealias Voxel = (Double, Double, Double)

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
    private var currentIndexInPredictionWindow = 0
    private var cancellable: AnyCancellable?
    public var online: Bool { motionManager.isDeviceMotionActive }

    public init() {}

    public func start(connection: ConnectionModel) {
        let socket = connection.socket
        queue.maxConcurrentOperationCount = 1
    
        guard !online else {
            return
        }

        cancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { _ in
                self.recognize()
            })

        motionManager.startDeviceMotionUpdates(to: self.queue) { [socket, self] data, error in
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
        }
    }

    public func stop() {
        defer { cancellable?.cancel() }

        guard online else {
            return
        }

        motionManager.stopDeviceMotionUpdates()
    }
}

extension MotionModelImpl {
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
    public init() {}
    public func start(connection: ConnectionModel) {}
    public func stop() {}
}
#endif
