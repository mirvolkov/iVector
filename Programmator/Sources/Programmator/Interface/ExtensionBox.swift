import Features

public protocol ExtensionBox: Codable, CustomStringConvertible {
    associatedtype T: Codable
    var isValid: Bool { get }
    var value: T? { get }
    mutating func setValue(_ value: T) throws
}

public extension ExtensionBox {
    var isValid: Bool { value != nil }
    var description: String {
        guard let value else { return "" }
        return "\(value)".uppercased()
    }
}

public enum ExtensionBoxError: Error {
    case invalidValue
}

public enum Extension {
    public class Distance: ExtensionBox {
        public var value: Int?

        public func setValue(_ value: Int) throws {
            let oldValue = self.value ?? 0
            guard oldValue < 100 else { throw ExtensionBoxError.invalidValue }
            self.value = oldValue*10 + value
        }

        public init(_ value: Int? = nil) {
            self.value = value
        }

        public var description: String {
            guard let value else { return "" }
            return "\(value)MM"
        }
    }

    public class Angle: ExtensionBox {
        public var value: Int?

        public func setValue(_ value: Int) throws {
            let oldValue = self.value ?? 0
            guard oldValue < 100 else { throw ExtensionBoxError.invalidValue }
            self.value = oldValue*10 + value
        }

        public init(_ value: Int? = nil) {
            self.value = value
        }

        public var description: String {
            guard let value else { return "" }
            return "\(value)°"
        }
    }

    public class Text: ExtensionBox {
        public var value: String?

        public func setValue(_ value: String) throws {
            self.value = value
        }

        public init(_ value: String? = nil) {
            self.value = value
        }
    }

    public class Time: ExtensionBox {
        public var value: Int?

        public func setValue(_ value: Int) throws {
            let oldValue = self.value ?? 0
            guard oldValue < 10 else { throw ExtensionBoxError.invalidValue }
            self.value = oldValue*10 + value
        }

        public init(_ value: Int? = nil) {
            self.value = value
        }

        public var description: String {
            guard let value else { return "" }
            return "\(value)SEC"
        }
    }

    public class Sound: ExtensionBox {
        public var value: SoundPlayer.SoundName?

        public func setValue(_ value: SoundPlayer.SoundName) throws {
            self.value = value
        }

        public init(_ value: SoundPlayer.SoundName? = nil) {
            self.value = value
        }
    }

    public class ProgramID: ExtensionBox {
        public var value: String?

        public func setValue(_ value: String) throws {
            self.value = value
        }

        public init(_ value: String? = nil) {
            self.value = value
        }

        public var description: String {
            guard let value else { return "" }
            return "#\(value)".uppercased()
        }
    }

    public class Condition: ExtensionBox {
        public var value: ConditionValue?

        public func setValue(_ value: ConditionValue) throws {
            self.value = value
        }

        public init() {
            self.value = nil
        }
    }

    public enum ConditionValue: Codable, CustomStringConvertible {
        case vision(VisionObject?)
        case sonar(Extension.Distance, ConditionType?)
        case text(Extension.Text?)

        public var description: String {
            switch self {
            case .vision(let object):
                guard let object else { return "VIS" }
                return "VIS(\(object))"
            case .sonar(let distance, let conformanceType):
                guard let conformanceType else { return "SON" }
                return "SON(\(conformanceType):\(distance))"
            case .text(let text):
                guard let text else { return "MSG" }
                return "MSG(\(text))"
            }
        }
    }

    public enum ConditionType: Codable, CustomStringConvertible {
        case less
        case eq
        case greater

        public var description: String {
            switch self {
            case .less:
                return "less"
            case .eq:
                return "eq"
            case .greater:
                return "greater"
            }
        }
    }
}
