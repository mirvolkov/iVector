import Combine
import Connection
import Foundation
import SwiftUI

public final class ConnectionViewModel: ObservableObject {
    @MainActor @Published public var isLoading: Bool = false
    @MainActor @Published public var isConnected: Bool = false
    @MainActor @Published public var battery: VectorBatteryState?
    
    private var bag = Set<AnyCancellable>()
    private let model: ConnectionModel
    
    public init(_ model: ConnectionModel) {
        self.model = model
        self.bind()
    }
    
    public func bind() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            Task {
                let result = try? await self.model.battery
                await MainActor.run {
                    self.battery = result
                }
            }
        }
        
        Task.detached { [self] in
            await model.bind()
            await self.model.state
                .map { newState in if case .connecting = newState { return true } else { return false } }
                .receive(on: RunLoop.main)
                .assign(to: \.isLoading, on: self)
                .store(in: &self.bag)
            await self.model.state
                .receive(on: RunLoop.main)
                .map { newState in if case .online = newState { return true } else { return false } }
                .assign(to: \.isConnected, on: self)
                .store(in: &self.bag)
        }
    }
    
    public func connect() {
        Task.detached { await self.model.connect(with: "192.168.0.105", port: 443) }
    }
    
    public func disconnect() {
        Task.detached { await self.model.disconnect() }
    }
}
