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
public final class MotionModelImpl: MotionModel {
    public typealias Voxel = (Double, Double, Double)

    static let predictionWindowSize = 100
    let model = try? collisionDetector.init(configuration: .init())
    let motionManager = CMMotionManager()
    var currentState = MotionModelImpl.stateInit()
    let accX = MotionModelImpl.axelInit()
    let accY = MotionModelImpl.axelInit()
    let accZ = MotionModelImpl.axelInit()
    let rotX = MotionModelImpl.axelInit()
    let rotY = MotionModelImpl.axelInit()
    let rotZ = MotionModelImpl.axelInit()
    let queue = OperationQueue()
    var currentIndexInPredictionWindow = 0
    var axelerometer: [Voxel] = []
    var gyroscope: [Voxel] = []

    public var online: Bool {
        motionManager.isDeviceMotionActive
    }

    public init() {}

    public func start(connection: ConnectionModel) {
        let socket = connection.socket

        guard !online else {
            return
        }

        motionManager.startDeviceMotionUpdates(to: self.queue) { [socket] data, _ in
            guard let data = data else { return }

            self.axelerometer.append((data.userAcceleration.x,
                                      data.userAcceleration.y,
                                      data.userAcceleration.z))

            self.gyroscope.append((data.rotationRate.x,
                                   data.rotationRate.y,
                                   data.rotationRate.z))

            if self.axelerometer.count >= 100 {
                Task {
                    try await socket?.send(
                        messages: self.axelerometer.map { [$0.0, $0.1, $0.2] },
                        with: "axelerometer"
                    )
                    self.axelerometer.removeAll()
                }
            }

            if self.gyroscope.count >= 100 {
                Task {
                    try await socket?.send(
                        messages: self.gyroscope.map { [$0.0, $0.1, $0.2] },
                        with: "gyroscope"
                    )
                    self.gyroscope.removeAll()
                }
            }

            self.rotX[self.currentIndexInPredictionWindow] = data.rotationRate.x as NSNumber
            self.rotY[self.currentIndexInPredictionWindow] = data.rotationRate.y as NSNumber
            self.rotZ[self.currentIndexInPredictionWindow] = data.rotationRate.z as NSNumber
            self.accX[self.currentIndexInPredictionWindow] = data.userAcceleration.x as NSNumber
            self.accY[self.currentIndexInPredictionWindow] = data.userAcceleration.y as NSNumber
            self.accZ[self.currentIndexInPredictionWindow] = data.userAcceleration.z as NSNumber
            self.currentIndexInPredictionWindow += 1
            if self.currentIndexInPredictionWindow == Self.predictionWindowSize {
                self.currentIndexInPredictionWindow = 0
            }

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

    public func stop() {
        motionManager.stopDeviceMotionUpdates()
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
