import Programmator

extension Programmator.Instruction: CPViewModelTag {}

extension Programmator.ExtensionBox: CPViewModelTag {}

extension ControlPanelViewModel {
    enum SecondaryTag: Int, CPViewModelTag {
        case btn0
        case btn1
        case btn2
        case btn3
        case btn4
        case btn5
        case btn6
        case btn7
        case btn8
        case btn9
    }

    enum AltTag: CPViewModelTag {
        case vision
        case sonar
        case stt
    }

    enum Mode {
        case primary
        case secondary
        case alt
    }

    func onConnected() {
        if isConnected {
            Task {
                try await connection.behavior?.setEyeColor(
                    settings.eyeColor.hsv.hueComponent,
                    settings.eyeColor.hsv.satComponent
                )
            }
        }
    }

    func tagButtons() {
        switch mode {
        case .primary:
            tagPrimary()
        case .secondary:
            tagSecondary()
        case .alt:
            tagAlt()
        }
    }

    func modeButtons() {
        switch mode {
        case .primary:
            buttons
                .filter { $0.key.starts(with: "BTN") }
                .forEach { value in
                    value.value.disableIcon = false
                    value.value.disableTitle = true
                    value.value.disableSecondary = true
                }

        case .secondary:
            buttons
                .filter { $0.key.starts(with: "BTN") }
                .forEach { value in
                    value.value.disableIcon = true
                    value.value.disableTitle = false
                    value.value.disableSecondary = true
                }

        case .alt:
            buttons
                .filter { $0.key.starts(with: "BTN") }
                .forEach { value in
                    value.value.disableIcon = true
                    value.value.disableTitle = true
                    value.value.disableSecondary = false
                }
        }
    }
}
