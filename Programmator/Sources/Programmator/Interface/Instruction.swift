public enum Instruction {
    case left(Double)
    case right(Double)
    case towards(Double)
    case backwards(Double)
    case play
    case say
    case dock
    case undock
    case liftUp
    case liftDown
    case rotate(Double)
    case goto(Program)
}
