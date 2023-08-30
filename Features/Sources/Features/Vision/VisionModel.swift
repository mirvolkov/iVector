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

    private let connection: ConnectionModel
    private var bag = Set<AnyCancellable>()
    private var cameraTask: Task<Void, Never>?

    public init(with connection: ConnectionModel) {
        self.connection = connection
    }

    public func bind() {
        connection
            .state
            .map { newState in if case .online = newState {
                return true
            } else {
                return false
            }
            }
            .receive(on: RunLoop.main)
            .assign(to: \.isVectorOnline, on: self)
            .store(in: &self.bag)

        $isVectorOnline
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { online in
                if online {
                    self.start()
                } else {
                    self.stop()
                }
            }
            .store(in: &self.bag)

        // getting frame here means stream failed. Restart in this case
        $frame
            .debounce(for: 10, scheduler: RunLoop.main)
            .filter { _ in
                self.isStreaming
            }
            .sink { _ in
                self.stop()
                self.start()
            }
            .store(in: &self.bag)
    }

    /// Start video feed
    public func start() {
        cameraTask = Task.detached {
            await MainActor.run { self.isStreaming = true }

            if let camera = try? self.connection.camera?.requestCameraFeed() {
                for await frame in camera {
                    if !self.isStreaming {
                        break
                    }

                    await MainActor.run {
                        self.frame = frame
                    }
                }
            }

            await MainActor.run { self.isStreaming = false }
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
