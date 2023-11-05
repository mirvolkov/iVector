// swiftlint:disable:next file_header
import Combine
import Connection
import Foundation
import SwiftUI

public final class VisionModel {
    /// is vector streaming video feed
    @Published public var isStreaming = false
    /// is vector connected and online
    @Published public var isVectorOnline = false
    /// last taken video frame
    @Published public var frame: VectorCameraFrame?

    private var bag = Set<AnyCancellable>()
    private var cameraTask: Task<Void, Never>?
    private let stream: AsyncStream<VectorCameraFrame>
    private let connection: ConnectionModel
    private var detector = ObjectDetection()
    private var isDetectorOn = false

    public init(with connection: ConnectionModel, stream: AsyncStream<VectorCameraFrame>) {
        self.stream = stream
        self.connection = connection
    }

    public func bind() {
        detector
            .objects
            .sink { objects in
                objects.forEach { [weak self] observation in
                    if let label = observation.labels.max(by: { $0.confidence < $1.confidence }) {
                        self?.connection.socket.send(event: VisionFeature.VisionObservation(
                            label: label.identifier,
                            confidence: label.confidence
                        ))
                    }
                }
            }
            .store(in: &bag)
    }

    /// Start video feed
    public func start() {
        cameraTask = Task.detached { [self] in
            await MainActor.run { isStreaming = true }

            for await frame in stream {
                if !isStreaming {
                    break
                }

                if isDetectorOn {
                    detector.process(frame.image)
                }

                await MainActor.run {
                    self.frame = frame
                }
            }

            await MainActor.run { isStreaming = false }
        }
    }

    /// Stop video feed
    public func stop() {
        cameraTask?.cancel()
        isStreaming = false
    }

    public func objectDetectionStart() {
        isDetectorOn = true
    }

    public func objectDetectionStop() {
        isDetectorOn = false
    }
}

extension VisionModel: Equatable {
    public static func == (lhs: VisionModel, rhs: VisionModel) -> Bool {
        true
    }
}

extension VisionModel: Sendable {}
