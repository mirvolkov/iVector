import Features

/** TODO: this model doesn't look like good solution. Consider refactoring + test coverage */
public enum ExtensionBox: CustomStringConvertible {
    case distance(Int)
    case angle(Int)
    case text(String)
    case sec(Int)
    case sound(SoundPlayer.SoundName?)

    case program(String)
    case condition(String)
    
    public var description: String {
        switch self {
        case .distance(let mm):
            return "\(mm)MM"
        case .angle(let rad):
            return "\(rad)°"
        case .text(let str):
            return "\(str.uppercased())"
        case .sec(let time):
            return "\(time)SEC"
        case .program(let name):
            return "\(name.uppercased())"
        case .condition(let condition):
            return "\(condition.uppercased())"
        case .sound(let name):
            return "\(name?.rawValue.uppercased() ?? "")"
        }
    }
}

extension ExtensionBox: Codable {}

public extension Instruction {
    var ext: ExtensionBox? {
        get {
            switch self {
            case .forward(let ext):
                return ext ?? .distance(0)
            case .backward(let ext):
                return ext ?? .distance(0)
            case .left(let ext):
                return ext ?? .distance(0)
            case .right(let ext):
                return ext ?? .distance(0)
            case .rotate(let ext):
                return ext ?? .angle(0)
            case .pause(let ext):
                return ext ?? .sec(0)
            case .say(let ext):
                return ext ?? .text("")
            case .play(let ext):
                return ext ?? .sound(.alarm)
            case .goto(let ifExt, let thenExt):
                guard let _ = ifExt else { return .condition("") }
                guard let thenExt = thenExt else { return .program("") }
                return thenExt
            default:
                return nil
            }
        }

        set {
            switch self {
            case .forward(_):
                self = .forward(newValue)
            case .backward(_):
                self = .backward(newValue)
            case .left(_):
                self = .left(newValue)
            case .right(_):
                self = .right(newValue)
            case .rotate(_):
                self = .rotate(newValue)
            case .pause(_):
                self = .pause(newValue)
            case .goto(let ifExt, let thenExt):
                if ifExt == nil {
                    self = .goto(newValue, nil)
                } else if thenExt == nil {
                    self = .goto(ifExt, newValue)
                }
            case .play(_):
                self = .play(newValue)
            case .say(_):
                self = .say(newValue)
            case .dock:
                self = .dock
            case .undock:
                self = .undock
            case .liftUp:
                self = .liftUp
            case .liftDown:
                self = .liftDown
            }
        }
    }

    mutating func pop() {
        switch self {
        case .forward(_):
            self = .forward(nil)
        case .backward(_):
            self = .backward(nil)
        case .left(_):
            self = .left(nil)
        case .right(_):
            self = .right(nil)
        case .rotate(_):
            self = .rotate(nil)
        case .pause(_):
            self = .pause(nil)
        case .goto(let ifExt, let thenExt):
            if thenExt != nil {
                self = .goto(ifExt, nil)
            } else if ifExt != nil {
                self = .goto(nil, nil)
            }
        default:
            break
        }
    }
}
