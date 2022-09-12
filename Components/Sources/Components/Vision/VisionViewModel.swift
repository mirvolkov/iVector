import Combine
import Connection
import Foundation
import SwiftUI

extension VisionView {
    @MainActor class ViewModel: ObservableObject {
        private let connection: ConnectionModel
        private var bag = Set<AnyCancellable>()
        
        @Published var isStreaming = false
        @Published var isVectorOnline = false
        @Published var frame: VectorCameraFrame?
        @Published var headAngle: UInt = 0
        
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
