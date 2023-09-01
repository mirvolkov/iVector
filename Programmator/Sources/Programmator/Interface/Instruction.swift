import Features

public protocol InstructionBox: Codable {
    var isValid: Bool { get }
}

public enum Instruction {
    case left(Extension.Distance)
    case right(Extension.Distance)
    case forward(Extension.Distance)
    case backward(Extension.Distance)
    case play(Extension.Sound)
    case say(Extension.Text)
    case dock(Bool)
    case lift(Bool)
    case rotate(Extension.Angle)
    case cmp(Extension.Condition, Extension.ProgramID)
    case exec(Extension.ProgramID)
    case pause(Extension.Time)
    case light(Bool)
    case laser(Bool)
}

extension Instruction: CustomStringConvertible {
    public var description: String {
        switch self {
        case .say(let ext):
            return "SAY \(ext.description)"
        case .dock(let isOn):
            return isOn ? "DOCK" : "UNDOCK"
        case .left(let ext):
            return "LEFT \(ext.description)"
        case .right(let ext):
            return "RIGHT \(ext.description)"
        case .forward(let ext):
            return "FWD \(ext.description)"
        case .backward(let ext):
            return "BWRD \(ext.description)"
        case .play(let ext):
            return "PLAY \(ext.description)"
        case .lift(let isOn):
            return isOn ? "LIFT" : "DOWN"
        case .rotate(let ext):
            return "ROT \(ext.description)"
        case .cmp(let ifExt, let thenExt):
            return "IF \(ifExt.description) \nTHEN \(thenExt.description)"
        case .exec(let ext):
            return "EXEC \(ext.description)"
        case .pause(let ext):
            return "PAUSE \(ext.description)"
        case .light(let isOn):
            return "LIGHT \(isOn ? 1 : 0)"
        case .laser(let isOn):
            return "LASER \(isOn ? 1 : 0)"
        }
    }
}

extension Instruction: InstructionBox {
    public var isValid: Bool {
        switch self {
        case .say(let ext):
            return ext.isValid
        case .dock:
            return true
        case .left(let ext):
            return ext.isValid
        case .right(let ext):
            return ext.isValid
        case .forward(let ext):
            return ext.isValid
        case .backward(let ext):
            return ext.isValid
        case .play(let ext):
            return ext.isValid
        case .lift:
            return true
        case .rotate(let ext):
            return ext.isValid
        case .cmp(let ifExt, let thenExt):
            return ifExt.isValid && thenExt.isValid
        case .exec(let ext):
            return ext.isValid
        case .pause(let ext):
            return ext.isValid
        case .light:
            return true
        case .laser:
            return true
        }
    }
}

public extension Instruction {
    mutating func setValue<T>(_ value: T) throws {
        switch (self, value) {
        case (.forward(let ext), let digit as Int):
            try ext.setValue(digit)
        case (.backward(let ext), let digit as Int):
            try ext.setValue(digit)
        case (.left(let ext), let digit as Int):
            try ext.setValue(digit)
        case (.right(let ext), let digit as Int):
            try ext.setValue(digit)
        case (.rotate(let ext), let digit as Int):
            try ext.setValue(digit)
        case (.say(let ext), let str as String):
            try ext.setValue(str)
        case (.exec(let ext), let program as Program):
            try ext.setValue(program.name)
        case (.pause(let ext), let digit as Int):
            try ext.setValue(digit)
        case (.play(let ext), let sound as SoundPlayer.SoundName):
            try ext.setValue(sound)
        case (.cmp(let condition, _), let conditionValue as Extension.ConditionValue):
            try condition.setValue(conditionValue)
        case (.cmp(let condition, _), let object as VisionObject):
            try condition.setValue(.vision(object))
        case (.cmp(let condition, _), let text as String):
            try condition.setValue(.text(.init(text)))
        case (.cmp(let condition, _), let cmp as Extension.ConditionType):
            try condition.setValue(.sonar(.init(), cmp))
        case (.cmp(let condition, _), let digit as Int):
            switch condition.value {
            case .sonar(let distance, _):
                try distance.setValue(digit)
            default:
                break
            }
        case (.cmp(let condition, _), let program as Program):
            self = .cmp(condition, .init(program.name))
        default:
            fatalError("\((self, value)) NOT IMPL")
        }
    }

    func getValue() -> (any ExtensionBox)? {
        switch self {
        case .forward(let value), .backward(let value), .left(let value), .right(let value):
            return value
        case .rotate(let value):
            return value
        case .say(let value):
            return value
        case .dock, .lift, .light, .laser:
            return nil
        case .exec(let value):
            return value
        case .pause(let value):
            return value
        case .play(let value):
            return value
        case .cmp(let condition, _):
            return condition
        }
    }
}
