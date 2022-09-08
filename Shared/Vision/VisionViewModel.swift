import Combine
import Connection
import Foundation
import Components

@MainActor class VisionViewModel: ObservableObject {
    private let connection: ConnectionModel
    private var bag = Set<AnyCancellable>()
    
    @Published var isStreaming = false
    @Published var isVectorOnline = false
    @Published var frame: VectorCameraFrame?
    
    init(with connection: ConnectionModel) {
        self.connection = connection
        Task.detached { @MainActor in
            await self.connection
                .state
                .map { newState in if case .online = newState { return true } else { return false } }
                .receive(on: RunLoop.main)
                .assign(to: \.isVectorOnline, on: self)
                .store(in: &self.bag)
        }
    }
    
    @MainActor func start() {
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
    
    @MainActor func stop() {
        isStreaming = false
    }
}
