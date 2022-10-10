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

    var digitalButtons: [any ControlPanelButtonViewModel] {
        [btn0, btn1, btn2, btn3, btn4, btn5, btn6, btn7, btn8, btn9]
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
            digitalButtons
                .forEach { value in
                    value.disableIcon = false
                    value.disableTitle = true
                    value.disableSecondary = true
                }

        case .secondary:
            digitalButtons
                .forEach { value in
                    value.disableIcon = true
                    value.disableTitle = false
                    value.disableSecondary = true
                }

        case .alt:
            digitalButtons
                .forEach { value in
                    value.disableIcon = true
                    value.disableTitle = true
                    value.disableSecondary = false
                }
        }
    }
}
