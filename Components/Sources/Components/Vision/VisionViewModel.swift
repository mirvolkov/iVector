import Combine
import Connection
import Features
import Foundation
import SwiftUI

extension VisionView {
    @MainActor public final class ViewModel: ObservableObject {
        /// is vector streaming video feed
        @Published var isStreaming = false
        /// last taken video frame
        @Published var frame: VectorCameraFrame?

        private let vision: VisionModel
        private var bag = Set<AnyCancellable>()
        private var cameraTask: Task<Void, Never>?

        public init(with vision: VisionModel) {
            self.vision = vision
        }

        /// Bind vision width viewmodel
        public func bind() {
            vision.$frame
                .receive(on: RunLoop.main)
                .weakAssign(to: \.frame, on: self)
                .store(in: &self.bag)

            vision.$isStreaming
                .receive(on: RunLoop.main)
                .weakAssign(to: \.isStreaming, on: self)
                .store(in: &self.bag)
        }

        /// Start video feed
        public func start() {
            vision.start()
        }

        /// Stop video feed
        public func stop() {
            vision.stop()
            isStreaming = false
        }
    }
}
