import Combine
import Connection
import CoreML
import CoreMotion
import NaturalLanguage
import SocketIO
import SwiftBus

public final class MotionDetector {
    public struct MotionLabel: EventRepresentable {
        public let label: String
    }

    public struct ExecutorEvent: EventRepresentable, SocketData, CustomStringConvertible {
        public enum Condition: EventRepresentable, CustomStringConvertible {
            case started
            case finished

            public var description: String {
                switch self {
                case .started:
                    "started"
                case .finished:
                    "finished"
                }
            }
        }

        public let instruction: String
        public let condition: Condition
        public let date: Date

        public init(instruction: String, condition: Condition, date: Date = Date()) {
            self.instruction = instruction
            self.condition = condition
            self.date = date
        }

        public var description: String {
            "\(condition.description):\(instruction):\(date.timeIntervalSince1970)"
        }
    }

    private static let windowSize = 100
    private var currentIndexInPredictionWindow = 0
    private var currentState = MotionDetector.stateInit()
    private let accX = MotionDetector.axelInit()
    private let accY = MotionDetector.axelInit()
    private let accZ = MotionDetector.axelInit()
    private let rotX = MotionDetector.axelInit()
    private let rotY = MotionDetector.axelInit()
    private let rotZ = MotionDetector.axelInit()
    private let instructions = MotionDetector.axelInit()
    private let heading = MotionDetector.axelInit()
    private let socket: SocketConnection

    private var cancellable: AnyCancellable?
    private let model = try? collisionDetector.init(configuration: .init())

    public init(with socket: SocketConnection) {
        self.socket = socket
    }

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
        socket.listen { [self] (event: ExecutorEvent) in
            print(event.description)
            Task {
                try? await socket.send(message: event.description, with: "exec")
            }
        }

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
                self.socket.send(event: MotionLabel(label: modelPrediction.label))
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
