// swiftlint:disable:next file_header
import Combine
import Connection
import Foundation
import SwiftUI

extension VectorCameraFrame: AppHub.SocketMessage {}

public final class VisionModel {
    /// is vector streaming video feed
    @Published public var isStreaming = false
    /// is vector connected and online
    @Published public var isVectorOnline = false
    /// last taken video frame
    @Published public var frame: VectorCameraFrame?
    /// objects on frame
    @Published public var objects: [VisionFeature.VisionObservation] = []

    private var bag = Set<AnyCancellable>()
    private var cameraTask: Task<Void, Never>?
    private let stream: AsyncStream<VectorCameraFrame>
    private let connection: ConnectionModel
    private lazy var invalidateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] _ in
        objects.removeAll { observation in
            observation.date.distance(to: .now) > 0.8
        }
    }

    public init(with connection: ConnectionModel, stream: AsyncStream<VectorCameraFrame>) {
        self.stream = stream
        self.connection = connection
    }

    /// Start video feed
    public func start() {
        invalidateTimer.fire()

        connection.hub.listen("vision") { [self] (observation: VisionFeature.VisionObservation) in
            objects.append(observation)
        }

        cameraTask = Task.detached { [self] in
            await MainActor.run { isStreaming = true }

            for await frame in stream {
                if !isStreaming {
                    break
                }

                connection.hub.send(frame, with: "camera")

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
}

extension VisionModel: Equatable {
    public static func == (lhs: VisionModel, rhs: VisionModel) -> Bool {
        true
    }
}

extension VisionModel: Sendable {}
