import SwiftUI

public func regular(_ size: CGFloat) -> SwiftUI.Font {
    SwiftUI.Font.init(FontFamily.RobotoMono.regular.font(size: size) as CTFont)
}

public func bold(_ size: CGFloat) -> SwiftUI.Font {
    SwiftUI.Font.init(FontFamily.RobotoMono.bold.font(size: size) as CTFont)
}

