import Features

/// Extension box existential wrapper protocol
/// T is a contained value type
/// isValid means if value is valid (usually it means it is not nil)
/// mutating func setValue - value setter
public protocol ExtensionBox: Codable, CustomStringConvertible {
    associatedtype T: Codable
    var isValid: Bool { get }
    var value: T? { get }
    mutating func setValue(_ value: T) throws
}

/// ExtensionBox default implementation
public extension ExtensionBox {
    var isValid: Bool {
        value != nil
    }

    var description: String {
        guard let value else { return "" }
        return "\(value)".uppercased()
    }
}

/// Extension box possible errors
public enum ExtensionBoxError: Error {
    case invalidValue
}

/// Extension box namespace
public enum Extension {
    /// Distance extension
    /// min: 0, max: 999
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

    /// Angle extension
    /// min: 0, max: 999
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

    /// Text extension
    /// max len 16 symbols
    public class Text: ExtensionBox {
        public var value: String?

        public func setValue(_ value: String) throws {
            guard value.count <= 16 else { throw ExtensionBoxError.invalidValue }
            self.value = value
        }

        public init(_ value: String? = nil) {
            self.value = value
        }
    }

    /// Time extension
    /// max value: 99 seconds
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

    /// Sound wrapper extension box
    public class Sound: ExtensionBox {
        public var value: SoundPlayer.SoundName?

        public func setValue(_ value: SoundPlayer.SoundName) throws {
            self.value = value
        }

        public init(_ value: SoundPlayer.SoundName? = nil) {
            self.value = value
        }
    }

    /// Program ID extension box
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

    /// Condition wrapper extension box
    /// - value ConditionValue enum
    public class Condition: ExtensionBox {
        public var value: ConditionValue?

        public func setValue(_ value: ConditionValue) throws {
            self.value = value
        }

        public init(_ value: ConditionValue? = nil) {
            self.value = value
        }
    }

    /// Condition value wrapper enum
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

    /// Condition type wrapper enum
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
