import Connection
import CoreML
import CoreMotion
import Foundation

#if os(iOS)
public final class MotionModel: @unchecked Sendable {
    static let predictionWindowSize = 100
    let model = try? collisionDetector.init(configuration: .init())
    let motionManager = CMMotionManager()
    var currentState = MotionModel.stateInit()
    let accX = MotionModel.axelInit()
    let accY = MotionModel.axelInit()
    let accZ = MotionModel.axelInit()
    let rotX = MotionModel.axelInit()
    let rotY = MotionModel.axelInit()
    let rotZ = MotionModel.axelInit()
    let queue = OperationQueue()
    var currentIndexInPredictionWindow = 0

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
            Task {
                try await socket?.send(
                    message: [
                        data.userAcceleration.x,
                        data.userAcceleration.y,
                        data.userAcceleration.z
                    ],
                    with: "axelerometer"
                )

                try await socket?.send(
                    message: [
                        data.rotationRate.x,
                        data.rotationRate.y,
                        data.rotationRate.z
                    ],
                    with: "gyroscope"
                )
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

extension MotionModel {
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
            shape: [MotionModel.predictionWindowSize] as [NSNumber],
            dataType: MLMultiArrayDataType.double
        )
    }
}
#endif
