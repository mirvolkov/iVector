import Programmator

extension Programmator.Instruction: CPViewModelTag {}

extension Extension.ConditionValue: CPViewModelTag {}

extension Extension.ConditionType: CPViewModelTag {}

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

    enum AltTag: Int, CPViewModelTag {
        case exec
    }

    enum Mode {
        case primary
        case secondary
        case alt
        case cmp
        case exec
    }

    private var digitalButtons: [any ControlPanelButtonViewModel] {
        [btn0, btn1, btn2, btn3, btn4, btn5, btn6, btn7, btn8, btn9]
    }

    private var behaviorButtons: [any ControlPanelButtonViewModel] {
        [tts, play, exec, liftBtn, laserBtn, dockBtn, lightBtn]
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
        case .cmp:
            tagCmp()
        case .exec:
            tagExec()
        }
    }

    func modeButtons() {
        switch mode {
        case .primary:
            digitalButtons.forEach { primary($0) }
            behaviorButtons.forEach { enable($0, enabled: true) }

        case .secondary:
            digitalButtons.forEach { secondary($0) }
            behaviorButtons.forEach { enable($0, enabled: false) }

        case .alt, .cmp:
            digitalButtons.forEach { alt($0) }
            behaviorButtons.forEach { enable($0, enabled: false) }

        case .exec:
            digitalButtons.forEach { enable($0, enabled: false) }
            behaviorButtons.forEach { enable($0, enabled: false) }
            exec.enabled = true
        }
    }

    private func enable(_ value: CPViewModelAvailability, enabled: Bool) {
        value.enabled = enabled
    }

    private func primary(_ value: CPViewModelAvailability) {
        value.disableIcon = false
        value.disableTitle = true
        value.disableSecondary = true
    }

    private func secondary(_ value: CPViewModelAvailability) {
        value.disableIcon = true
        value.disableTitle = false
        value.disableSecondary = true
    }

    private func alt(_ value: CPViewModelAvailability) {
        value.disableIcon = true
        value.disableTitle = true
        value.disableSecondary = false
    }
}
