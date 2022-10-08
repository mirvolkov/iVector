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
            
            assembler.$current
                .map { $0?.description }
                .assign(to: \.command, on: self)
                .store(in: &bag)
            
            assembler.$current
                .receive(on: RunLoop.main)
                .sink { value in
                    self.mode = value == nil ? .primary : .secondary
                }
                .store(in: &bag)
            
            esc.$onEsc
                .filter { $0 }
                .receive(on: RunLoop.main)
                .sink { value in
                    self.assembler.esc()
                }
                .store(in: &bag)

            enter.$onEnter
                .filter { $0 }
                .receive(on: RunLoop.main)
                .sink { value in
                    self.assembler.enter()
                }
                .store(in: &bag)

            save.$showSavePopover
                .receive(on: RunLoop.main)
                .assign(to: \.showSavePopover, on: self)
                .store(in: &bag)

            save.$saveError
                .receive(on: RunLoop.main)
                .assign(to: \.saveError, on: self)
                .store(in: &bag)
        }
    }

    func unbind() {
        bag.removeAll()
    }
}
