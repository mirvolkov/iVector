import Combine
import SwiftUI

extension ControlPanelViewModel {
    func bind() {
        Task { @MainActor [self] in
            await self.connection.state
                .receive(on: RunLoop.main)
                .map { newState in if case .online = newState { return true } else { return false } }
                .assign(to: \.isConnected, on: self)
                .store(in: &self.bag)
            
            tts.$ttsAlert
                .assign(to: \.ttsAlert, on: self)
                .store(in: &bag)
            
            play.$showAudioListPopover
                .assign(to: \.playPopover, on: self)
                .store(in: &bag)
        }
    }
    
    func unbind() {
        bag.removeAll()
    }
}
