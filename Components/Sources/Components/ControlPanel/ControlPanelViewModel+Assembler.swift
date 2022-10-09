import Combine
import Programmator

extension ControlPanelViewModel {
    func tagInitial() {
        dockBtn.tag = Instruction.dock
        undockBtn.tag = Instruction.undock
        lift.tag = Instruction.liftUp
        down.tag = Instruction.liftDown
    }

    func tagPrimary() {
        btn0.tag = Instruction.goto(nil, nil)
        btn1.tag = nil
        btn2.tag = Instruction.forward(nil)
        btn3.tag = nil
        btn4.tag = Instruction.left(nil)
        btn5.tag = Instruction.rotate(nil)
        btn6.tag = Instruction.right(nil)
        btn7.tag = nil
        btn8.tag = Instruction.backward(nil)
        btn9.tag = nil
        pause.tag = Instruction.pause(nil)
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
    }

    func tagAlt() {
        btn0.tag = nil
        btn1.tag = nil
        btn2.tag = nil
        btn3.tag = nil
        btn4.tag = nil
        btn5.tag = nil
        btn6.tag = nil
        btn7.tag = AltTag.vision
        btn8.tag = AltTag.sonar
        btn9.tag = AltTag.stt
        pause.tag = nil
    }
}
