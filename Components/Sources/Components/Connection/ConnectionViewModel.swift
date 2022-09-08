import Combine
import Connection
import Foundation
import SwiftUI

@MainActor public final class ConnectionViewModel: ObservableObject {
    @Published public var isLoading: Bool = false
    @Published public var isConnected: Bool = false {
        didSet {
            if isConnected {
                Task {
                    try await model.behavior?.setEyeColor(
                        settings.eyeColor.hsv.hueComponent,
                        settings.eyeColor.hsv.satComponent
                    )
                    
//                    try await model.say(text: "Hello we are from Ukraine")
                }
            }
        }
    }

    @Published public var battery: VectorBatteryState?
    
    private var bag = Set<AnyCancellable>()
    private let model: ConnectionModel
    private let settings: SettingsModel
    
    public init(_ model: ConnectionModel, settings: SettingsModel) {
        self.model = model
        self.settings = settings
        bind()
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
        
        Task.detached { @MainActor [self] in
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
        Task.detached {
            await self.model.connect(
                with: self.settings.ip,
                port: self.settings.port
            )
        }
    }
    
    public func disconnect() {
        Task.detached { await self.model.disconnect() }
    }
    
    public func dock() {
        Task.detached { try? await self.model.dock() }
    }
    
    public func undock() {
        Task.detached { try? await self.model.undock() }
    }
}
