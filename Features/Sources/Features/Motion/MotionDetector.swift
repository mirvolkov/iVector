import Combine
import Connection
import CoreML
import CoreMotion
import NaturalLanguage
import SocketIO
import SwiftBus

public final class MotionDetector {
    fileprivate enum Const {
        static let windowSize = 50
        static let currentStateSize = 400
    }

    public var callback: (Motion.MotionLabel) -> () = { _ in }

    private var window = 0
    private var currentState = MotionDetector.stateInit()
    private let accX = MotionDetector.axelInit()
    private let accY = MotionDetector.axelInit()
    private let accZ = MotionDetector.axelInit()
    private let instructions = MotionDetector.axelInit()
    private let heading = MotionDetector.axelInit()
    private var cancellable: AnyCancellable?
    private let model = try? col.init(configuration: .init())

    public init() {}

    public func pushAccelerometer(_ data: CMAcceleration) {
        accX[window] = data.x as NSNumber
        accY[window] = data.y as NSNumber
        accZ[window] = data.z as NSNumber
    }

    public func pushHeading(_ data: Double) {
        heading[window] = data as NSNumber
    }

    public func step() {
        window += 1
        if window == Const.windowSize - 1 {
            window = 0
        }
    }

    public func motionRecognitionStart() {
        cancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { [weak self] _ in
                self?.recognize()
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
                self.callback(Motion.MotionLabel(label: modelPrediction.label))
            }
        }
    }

    private static func stateInit() -> MLMultiArray {
        // swiftlint:disable:next force_try
        try! MLMultiArray(
            Array(repeating: Double(0), count: Const.currentStateSize)
        )
    }

    private static func axelInit() -> MLMultiArray {
        // swiftlint:disable:next force_try
        try! MLMultiArray(
            shape: [Const.windowSize] as [NSNumber],
            dataType: MLMultiArrayDataType.double
        )
    }
}
