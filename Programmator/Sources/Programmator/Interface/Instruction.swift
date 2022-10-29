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
    case cmp(ExtensionBox?, ExtensionBox?)
    case exec(ExtensionBox?)
    case pause(ExtensionBox?)
}

extension Instruction: CustomStringConvertible {
    public var description: String {
        let descr: (ExtensionBox?) -> String = { ext in
            return ext?.description ?? ""
        }

        switch self {
        case .say(let ext):
            return "SAY \(descr(ext))"
        case .dock:
            return "DOCK"
        case .undock:
            return "UNDOCK"
        case .left(let ext):
            return "LEFT \(descr(ext))"
        case .right(let ext):
            return "RIGHT \(descr(ext))"
        case .forward(let ext):
            return "FWD \(descr(ext))"
        case .backward(let ext):
            return "BWRD \(descr(ext))"
        case .play(let ext):
            return "PLAY \(descr(ext))"
        case .liftUp:
            return "UP"
        case .liftDown:
            return "DOWN"
        case .rotate(let ext):
            return "ROT \(descr(ext))"
        case .cmp(let ifExt, let thenExt):
            if let ifExt {
               return "IF \(ifExt.description) \nTHEN \(descr(thenExt))"
            }
            return "IF \(descr(ifExt))"
        case .exec(let ext):
            return "EXEC \(descr(ext))"
        case .pause(let ext):
            return "PAUSE \(descr(ext))"
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
        case .cmp(let ifExt, let thenExt):
            return ifExt != nil && thenExt != nil
        case .exec(let ext):
            return ext != nil
        case .pause(let ext):
            return ext != nil
        }
    }
}

extension Instruction: Codable {}
