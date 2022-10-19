import Combine
import SwiftUI

extension ControlPanelViewModel {
    func bind() {
        Task { @MainActor [self] in
            await self.connection.state
                .receive(on: RunLoop.main)
                .map { newState in if case .online = newState { return true } else { return false } }
                .weakAssign(to: \.isConnected, on: self)
                .store(in: &self.bag)

            assembler.$current
                .receive(on: RunLoop.main)
                .map { $0?.ext }
                .map { ext in
                    guard let ext = ext else { return .primary }
                    switch ext {
                    case .sound, .text:
                        return .primary
                    case .sec, .angle, .distance:
                        return .secondary
                    case .condition, .program:
                        return .alt
                    }
                }
                .assign(to: \.mode, on: self)
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

            bind(with: assembler.$current.map { $0?.description }, destination: \.command)
            bind(with: play.$showAudioListPopover, destination: \.playPopover)
            bind(with: tts.$ttsAlert, destination: \.ttsAlert)
            bind(with: save.$showSavePopover, destination: \.showSavePopover)
            bind(with: save.$saveError, destination: \.saveError)
            bind(with: goto.$showPrograms, destination: \.showPrograms)
        }
    }

    func unbind() {
        bag.removeAll()
    }

    private func bind<T: Publisher>(with object: T, destination: ReferenceWritableKeyPath<ControlPanelViewModel, T.Output>) where T.Failure == Never {
        object
            .receive(on: RunLoop.main)
            .weakAssign(to: destination, on: self)
            .store(in: &bag)
    }
}
