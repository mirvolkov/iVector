import SwiftUI

/// Color extension to let color be archived and used with AppStorage wrapper
/// - Description implementation works with iOS/macOS envs
extension Color: RawRepresentable {
    public init?(rawValue: String) {
        guard let data = Data(base64Encoded: rawValue) else {
            self = .black
            return
        }

#if os(iOS)
        do {
            let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor ?? .black
            self = Color(color)
        } catch {
            self = .black
        }
#elseif os(macOS)
        do {
            let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? NSColor ?? .black
            self = Color(color)
        } catch {
            self = .white
        }
#endif
    }

    public var rawValue: String {
#if os(iOS)
        do {
            let data = try NSKeyedArchiver.archivedData(
                withRootObject: UIColor(self),
                requiringSecureCoding: false
            ) as Data
            return data.base64EncodedString()
        } catch {
            return ""
        }
#elseif os(macOS)
        do {
            let data = try NSKeyedArchiver.archivedData(
                withRootObject: NSColor(self),
                requiringSecureCoding: false
            ) as Data
            return data.base64EncodedString()
        } catch {
            return ""
        }
#endif
    }
}
