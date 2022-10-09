public protocol InstructionBox {
    var isValid: Bool { get }
}

public enum Instruction {
    case left(ExtensionBox?)
    case right(ExtensionBox?)
    case forward(ExtensionBox?)
    case backward(ExtensionBox?)
    case play(ExtensionBox?)
    case say(ExtensionBox?)
    case dock
    case undock
    case liftUp
    case liftDown
    case rotate(ExtensionBox?)
    case goto(ExtensionBox?, ExtensionBox?)
}

extension Instruction: CustomStringConvertible {
    public var description: String {
        switch self {
        case .say(let ext):
            return "SAY \(ext?.description ?? "")"
        case .dock:
            return "dock"
        case .undock:
            return "undock"
        case .left(let ext):
            return "LEFT \(ext?.description ?? "")"
        case .right(let ext):
            return "RIGHT \(ext?.description ?? "")"
        case .forward(let ext):
            return "FWD \(ext?.description ?? "")"
        case .backward(let ext):
            return "BWRD \(ext?.description ?? "")"
        case .play(let ext):
            return "PLAY \(ext?.description ?? "")"
        case .liftUp:
            return "UP"
        case .liftDown:
            return "DOWN"
        case .rotate(let ext):
            return "ROT \(ext?.description ?? "")"
        case .goto(let ifExt, let thenExt):
            if let ifExt {
               return "IF \(ifExt.description) THEN \(thenExt?.description ?? "")"
            }
            return "IF \(ifExt?.description ?? "")"
        }
    }
}

extension Instruction: InstructionBox {
    public var isValid: Bool {
        switch self {
        case .say(let ext):
            return ext != nil
        case .dock:
            return true
        case .undock:
            return true
        case .left(let ext):
            return ext != nil
        case .right(let ext):
            return ext != nil
        case .forward(let ext):
            return ext != nil
        case .backward(let ext):
            return ext != nil
        case .play(let ext):
            return ext != nil
        case .liftUp:
            return true
        case .liftDown:
            return true
        case .rotate(let ext):
            return ext != nil
        case .goto(let ifExt, let thenExt):
            return ifExt != nil && thenExt != nil
        }
    }
}

extension Instruction: Codable { }
