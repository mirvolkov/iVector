import Combine
import CoreML
import CoreMotion
import SwiftBus

public final class MotionDetector {
    public struct MotionLabel: EventRepresentable {
        public let label: String
    }

    static let windowSize = 100
    var currentIndexInPredictionWindow = 0
    var currentState = MotionDetector.stateInit()
    let accX = MotionDetector.axelInit()
    let accY = MotionDetector.axelInit()
    let accZ = MotionDetector.axelInit()
    let rotX = MotionDetector.axelInit()
    let rotY = MotionDetector.axelInit()
    let rotZ = MotionDetector.axelInit()
    let heading = MotionDetector.axelInit()
    var onRecognize: (MotionLabel) -> () = { _ in }

    private var cancellable: AnyCancellable?
    private let model = try? collisionDetector.init(configuration: .init())

    public func pushAccelerometer(_ data: CMAcceleration) {
        accX[currentIndexInPredictionWindow] = data.x as NSNumber
        accY[currentIndexInPredictionWindow] = data.y as NSNumber
        accZ[currentIndexInPredictionWindow] = data.z as NSNumber
    }

    public func pushRotation(_ data: CMRotationRate) {
        rotX[currentIndexInPredictionWindow] = data.x as NSNumber
        rotY[currentIndexInPredictionWindow] = data.y as NSNumber
        rotZ[currentIndexInPredictionWindow] = data.z as NSNumber
    }

    public func pushHeading(_ data: Double) {
        heading[currentIndexInPredictionWindow] = data as NSNumber
    }

    public func step() {
        currentIndexInPredictionWindow += 1
        if currentIndexInPredictionWindow == Self.windowSize - 1 {
            currentIndexInPredictionWindow = 0
        }
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

    private func recognize() {
        autoreleasepool {
            if let modelPrediction = try? self.model?.prediction(
                x: self.accX,
                y: self.accY,
                z: self.accZ,
                stateIn: self.currentState
            ) {
                self.currentState = modelPrediction.stateOut
                self.onRecognize(MotionLabel(label: modelPrediction.label))
            }
        }
    }

    private static func stateInit() -> MLMultiArray {
        // swiftlint:disable:next force_try
        try! MLMultiArray(
            shape: [400 as NSNumber],
            dataType: MLMultiArrayDataType.double
        )
    }

    private static func axelInit() -> MLMultiArray {
        // swiftlint:disable:next force_try
        try! MLMultiArray(
            shape: [Self.windowSize] as [NSNumber],
            dataType: MLMultiArrayDataType.double
        )
    }
}
