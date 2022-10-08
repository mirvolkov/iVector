import Programmator

protocol ControlPanelViewModelHandling {
    func onTag(_ tag: CPViewModelTag)
}

extension ControlPanelViewModel: ControlPanelViewModelHandling {
    func onTag(_ tag: CPViewModelTag) {
        if let instruction = tag as? Instruction {
            assembler.current = instruction
        }
        if let ext = tag as? SecondaryTag {
            assembler.extend(with: ext.rawValue)
        }
    }
}
