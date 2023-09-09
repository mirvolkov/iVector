import SwiftUI

#if os(macOS)
public enum UserInterfaceSizeClass {
    case compact
    case regular
}

public struct HorizontalSizeClassEnvironmentKey: EnvironmentKey {
    public static let defaultValue: UserInterfaceSizeClass = .compact
}

public struct VerticalSizeClassEnvironmentKey: EnvironmentKey {
    public static let defaultValue: UserInterfaceSizeClass = .regular
}

public extension EnvironmentValues {
    var horizontalSizeClass: UserInterfaceSizeClass {
        get { return self[HorizontalSizeClassEnvironmentKey.self] }
        set { self[HorizontalSizeClassEnvironmentKey.self] = newValue }
    }
    var verticalSizeClass: UserInterfaceSizeClass {
        get { return self[VerticalSizeClassEnvironmentKey.self] }
        set { self[VerticalSizeClassEnvironmentKey.self] = newValue }
    }
}
#endif
