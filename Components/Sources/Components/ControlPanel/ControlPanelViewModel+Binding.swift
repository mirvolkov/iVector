import Combine
import Programmator
import SwiftUI

extension ControlPanelViewModel {
    func bind() {
        connection.connectionState
            .receive(on: RunLoop.main)
            .map { newState in if case .online = newState { return true } else { return false } }
            .weakAssign(to: \.isConnected, on: self)
            .store(in: &self.bag)
        
        assembler.$current
            .receive(on: RunLoop.main)
            .map { [unowned self] current in
                self.reactToCurrent(current)
            }
            .assign(to: \.mode, on: self)
            .store(in: &bag)

        esc.$onEsc
            .filter { $0 }
            .receive(on: RunLoop.main)
            .sink { _ in
                self.assembler.esc()
            }
            .store(in: &bag)

        enter.$onEnter
            .filter { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.assembler.enter()
            }
            .store(in: &bag)

        save.$saveError
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.saveError?.handle(error: error)
            }
            .store(in: &bag)

        bind(with: assembler.$current.map { $0?.description }, destination: \.command)
        bind(with: play.$showAudioListPopover, destination: \.playPopover)
        bind(with: tts.$ttsAlert, destination: \.ttsAlert)
        bind(with: save.$showSavePopover, destination: \.showSavePopover)
        bind(with: exec.$showPrograms, destination: \.showPrograms)
        bind(with: btn7.$showVisionObjects, destination: \.showVisionObjects)
        bind(with: btn9.$showTextRequest, destination: \.showTextRequest)
    }

    func unbind() {
        bag.removeAll()
    }

    private func reactToCurrent(_ current: Instruction?) -> Mode {
        guard let ext = current?.getValue() else { return .primary }
        switch ext {
        case _ as Extension.Distance:
            return .secondary
        case _ as Extension.Angle:
            return .secondary
        case _ as Extension.Time:
            return .secondary
        case let condition as Extension.Condition:
            return reactToCondition(condition)
        case _ as Extension.ProgramID:
            return .alt
        default:
            return .primary
        }
    }

    private func reactToCondition(_ condition: Extension.Condition) -> Mode {
        if let value = condition.value {
            switch value {
            case .vision(let object):
                return object == nil ? .alt : .exec
            case .text(let text):
                return text == nil ? .alt : .exec
            case .sonar(_, let cmp):
                return cmp == nil ? .cmp : .secondary
            }
        }

        return .alt
    }

    private func bind<T: Publisher>(with object: T, destination: ReferenceWritableKeyPath<ControlPanelViewModel, T.Output>) where T.Failure == Never {
        object
            .receive(on: RunLoop.main)
            .weakAssign(to: destination, on: self)
            .store(in: &bag)
    }
}
