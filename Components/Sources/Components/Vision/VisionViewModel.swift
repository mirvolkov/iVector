import Combine
import Connection
import Foundation
import SwiftUI

extension VisionView {
    @MainActor class ViewModel: ObservableObject {
        /// is vector streaming video feed
        @Published var isStreaming = false
        /// is vector connected and online
        @Published var isVectorOnline = false
        /// last taken video frame
        @Published var frame: VectorCameraFrame?
        /// vector's head angle. Degrees (-22...45)
        @Published var headAngle: UInt = 0
        
        private let connection: ConnectionModel
        private var bag = Set<AnyCancellable>()
        
        public init(with connection: ConnectionModel) {
            self.connection = connection
            Task.detached { @MainActor in
                await self.connection
                    .state
                    .map { newState in if case .online = newState { return true } else { return false } }
                    .receive(on: RunLoop.main)
                    .assign(to: \.isVectorOnline, on: self)
                    .store(in: &self.bag)
                
                self.$headAngle
                    .dropFirst()
                    .map { $0 }
                    .debounce(for: 0.5, scheduler: RunLoop.main)
                    .sink { value in
                        Task {
                            let angle = self.denorm(value)
                            try await self.connection.behavior?.setHeadAngle(angle)
                        }
                    }
                    .store(in: &self.bag)
                
                self.$isVectorOnline
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
                
                await self.connection
                    .robotState
                    .first()
                    .map { $0.headAngleRad }
                    .map { Angle(radians: Double($0)) }
                    .map { self.norm($0.degrees) }
                    .receive(on: RunLoop.main)
                    .assign(to: \.headAngle, on: self)
                    .store(in: &self.bag)
            }
        }
        
        deinit {
            print("VisionViewModel deinit")
        }
        
        /// Start video feed
        @MainActor public func start() {
            Task.detached {
                await MainActor.run { self.isStreaming = true }
                
                if let camera = try? await self.connection.camera {
                    for await frame in camera {
                        if await !self.isStreaming {
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
        @MainActor public func stop() {
            isStreaming = false
        }
        
        func norm(_ value: Double) -> UInt {
            let min: Double = -22
            let max: Double = 45
            return UInt(100 * (value - min) / (max - min))
        }
        
        func denorm(_ value: UInt) -> Float {
            let min: Float = -22
            let max: Float = 45
            return Float(100 - value) / 100.0 * (max - min) + min
        }
    }
}
