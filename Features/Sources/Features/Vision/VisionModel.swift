import Combine
import Connection
import Foundation
import SwiftUI

public class VisionModel {
    /// is vector streaming video feed
    @Published public var isStreaming = false
    /// is vector connected and online
    @Published public var isVectorOnline = false
    /// last taken video frame
    @Published public var frame: VectorCameraFrame?

    private var bag = Set<AnyCancellable>()
    private var cameraTask: Task<Void, Never>?
    private var stream: AsyncStream<VectorCameraFrame>

    public init(with stream: AsyncStream<VectorCameraFrame>) {
        self.stream = stream
    }

    public func bind() {}

    /// Start video feed
    public func start() {
        cameraTask = Task.detached { [self] in
            await MainActor.run { isStreaming = true }

            for await frame in stream {
                if !isStreaming {
                    break
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
}

extension VisionModel: Equatable {
    public static func == (lhs: VisionModel, rhs: VisionModel) -> Bool {
        true
    }
}

extension VisionModel: Sendable { }
