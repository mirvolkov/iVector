import SwiftUI

public func regular(_ size: CGFloat) -> SwiftUI.Font {
    SwiftUI.Font.init(FontFamily.RobotoMono.regular.font(size: 32) as CTFont)
}

public func bold(_ size: CGFloat) -> SwiftUI.Font {
    SwiftUI.Font.init(FontFamily.RobotoMono.bold.font(size: 32) as CTFont)
}

