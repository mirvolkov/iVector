import Combine
import Programmator

extension ControlPanelViewModel {
    func tagInitial() {
        tts.tag = Instruction.say(.init())
        play.tag = Instruction.play(.init())
        exec.tag = Instruction.exec(.init())
    }

    func tagPrimary() {
        btn0.tag = Instruction.cmp(.init(), .init())
        btn1.tag = nil
        btn2.tag = Instruction.forward(.init())
        btn3.tag = nil
        btn4.tag = Instruction.left(.init())
        btn5.tag = Instruction.rotate(.init())
        btn6.tag = Instruction.right(.init())
        btn7.tag = nil
        btn8.tag = Instruction.backward(.init())
        btn9.tag = nil
        pause.tag = Instruction.pause(.init())
        exec.tag = Instruction.exec(.init())
    }

    func tagSecondary() {
        btn0.tag = SecondaryTag.btn0
        btn1.tag = SecondaryTag.btn1
        btn2.tag = SecondaryTag.btn2
        btn3.tag = SecondaryTag.btn3
        btn4.tag = SecondaryTag.btn4
        btn5.tag = SecondaryTag.btn5
        btn6.tag = SecondaryTag.btn6
        btn7.tag = SecondaryTag.btn7
        btn8.tag = SecondaryTag.btn8
        btn9.tag = SecondaryTag.btn9
        pause.tag = nil
        exec.tag = AltTag.exec
    }

    func tagAlt() {
        btn0.tag = nil
        btn1.tag = nil
        btn2.tag = nil
        btn3.tag = nil
        btn4.tag = nil
        btn5.tag = nil
        btn6.tag = nil
        btn7.tag = Extension.ConditionValue.vision(nil)
        btn8.tag = Extension.ConditionValue.sonar(.init(), nil)
        btn9.tag = Extension.ConditionValue.text(nil)
        pause.tag = nil
        exec.tag = AltTag.exec
    }

    func tagCmp() {
        btn0.tag = nil
        btn1.tag = nil
        btn2.tag = nil
        btn3.tag = nil
        btn4.tag = Extension.ConditionType.less
        btn5.tag = Extension.ConditionType.eq
        btn6.tag = Extension.ConditionType.greater
        btn7.tag = nil
        btn8.tag = nil
        btn9.tag = nil
        pause.tag = nil
        exec.tag = nil
    }

    func tagExec() {
        exec.tag = AltTag.exec
    }
}
