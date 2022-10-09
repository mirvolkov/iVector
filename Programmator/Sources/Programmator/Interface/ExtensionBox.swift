/** TODO: this model doesn't look like good solution. Consider refactoring + test coverage */
public enum ExtensionBox: CustomStringConvertible {
    case distance(Int)
    case angle(Int)
    case text(String)
    
    case program(String)
    case condition(String)
    
    public var description: String {
        switch self {
        case .distance(let mm):
            return "\(mm)MM"
        case .angle(let rad):
            return "\(rad)°"
        case .text(let str):
            return "\(str)"
        case .program(let name):
            return "\(name.uppercased())"
        case .condition(let condition):
            return "\(condition.uppercased())"
        }
    }
}

extension ExtensionBox: Codable {
}

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
                
            case .goto(let ifExt, let thenExt):
                if let thenExt = thenExt {
                    return thenExt
                }
                if let ifExt = ifExt {
                    return ifExt
                }
                return nil

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
                
            case .goto(let ifExt, let thenExt):
                if ifExt == nil {
                    self = .goto(newValue, nil)
                } else if thenExt == nil {
                    self = .goto(ifExt, newValue)
                }

            default:
                break
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
