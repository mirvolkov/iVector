import Foundation

public enum VectorBatteryState: CustomStringConvertible {
    case charging
    case low
    case normal
    case full
    case unknown

    init(with entity: Anki_Vector_ExternalInterface_BatteryLevel) {
        switch entity {
        case .unknown:
            self = .unknown

        case .low:
            self = .low

        case .nominal:
            self = .normal

        case .full:
            self = .full

        case .UNRECOGNIZED:
            self = .unknown
        }
    }

    public var description: String {
        switch self {
        case .charging:
            return "charging"
        case .full:
            return "full"
        case .normal:
            return "normal"
        case .low:
            return "low"
        case .unknown:
            return "unknown"
        }
    }
}

/// Vector's behaviour API
public protocol Behavior {
    /// Request vector say some text
    /// - Throws error if request failed
    func say(text: String) async throws

    /// Sets eye color
    /// - Parameter hue value 0..1
    /// - Throws error set eye color failed
    func setEyeColor(_ hue: Float, _ sat: Float) async throws

    /// Set head angle
    /// - Parameter angle 22.000000..45.000000 range
    /// - Throws set angle error failed
    func setHeadAngle(_ angle: Float) async throws

    /// Lift
    /// - Parameter height 0...1 range
    /// - Throws lift error failed
    func lift(_ height: Float) async throws

    /// Move
    /// - Parameter distance - distance in mm
    /// - Parameter speed (mm per sec)
    /// - Parameter animate should_play_animation (default False)
    /// - Throws error if request failed
    func move(_ distance: Float, speed: Float, animate: Bool) async throws

    /// Turn in place
    /// - Parameter angle (rad)
    /// - Parameter speed (mm per sec)
    /// - Parameter accel Acceleration of angular turn(per second squared).
    /// - Parameter angle_tolerance angular tolerance to consider the action complete (this is clamped to a minimum of 2 degrees internally)
    /// - Throws error if request failed
    func turn(_ angle: Float, speed: Float, accel: Float, angleTolerance: Float) async throws

    /// Drive off charger
    /// - Throws error if request failed
    func driveOffCharger() async throws

    /// Drive on charger
    /// - Throws error if request failed
    func driveOnCharger() async throws

    /// Read battery state
    /// - Returns battery state
    /// - Throws if reading failed
    var battery: VectorBatteryState { get async throws }
}
