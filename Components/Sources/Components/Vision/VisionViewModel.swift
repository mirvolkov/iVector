import Combine
import Connection
import Features
import Foundation
import SwiftUI

extension VisionView {
    @MainActor class ViewModel: ObservableObject {
        /// is vector streaming video feed
        @Published var isStreaming = false
        /// last taken video frame
        @Published var frame: VectorCameraFrame?
        /// vector's head angle. Degrees (0...100)
        @Published var headAngle: UInt = 0
        
        private let vision: VisionModel
        private let connection: ConnectionModel
        private var bag = Set<AnyCancellable>()
        private var cameraTask: Task<Void, Never>?
        
        public init(with connection: ConnectionModel, vision: VisionModel) {
            self.connection = connection
            self.vision = vision
            Task.detached { @MainActor in
                self.vision.$frame
                    .receive(on: RunLoop.main)
                    .weakAssign(to: \.frame, on: self)
                    .store(in: &self.bag)
                
                self.vision.$isStreaming
                    .receive(on: RunLoop.main)
                    .weakAssign(to: \.isStreaming, on: self)
                    .store(in: &self.bag)
                
                self.$headAngle
                    .dropFirst()
                    .map { $0 }
                    .debounce(for: 0.5, scheduler: RunLoop.main)
                    .sink { [weak self] value in
                        Task {
                            if let angle = self?.normToDegree(value) {
                                try await self?.connection.behavior?.setHeadAngle(angle)
                            }
                        }
                    }
                    .store(in: &self.bag)

                await self.connection
                    .robotState
                    .first()
                    .map { $0.headAngleRad }
                    .map { Angle(radians: Double($0)) }
                    .map { self.degreeToNorm($0.degrees) }
                    .receive(on: RunLoop.main)
//                    .weakAssign(to: \.headAngle, on: self)
                    .sink(receiveValue: { val in
                        print(val)
                        self.headAngle = val
                    })
                    .store(in: &self.bag)
            }
        }
        
        /// Start video feed
        @MainActor public func start() {
            vision.start()
        }
        
        /// Stop video feed
        @MainActor public func stop() {
            vision.stop()
            isStreaming = false
        }
        
        func degreeToNorm(_ value: Double) -> UInt {
            let min: Double = -22
            let max: Double = 45
            return UInt(100 * (value - min) / (max - min))
        }
        
        func normToDegree(_ value: UInt) -> Float {
            let min: Float = -22
            let max: Float = 45
            return Float(100 - value) / 100.0 * (max - min) + min
        }
    }
}
