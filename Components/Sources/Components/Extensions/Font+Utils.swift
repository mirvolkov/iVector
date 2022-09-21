import SwiftUI

public func vectorRegular(_ size: CGFloat) -> SwiftUI.Font {
    SwiftUI.Font.init(FontFamily.RobotoMono.regular.font(size: size) as CTFont)
}

public func vectorBold(_ size: CGFloat) -> SwiftUI.Font {
    SwiftUI.Font.init(FontFamily.RobotoMono.bold.font(size: size) as CTFont)
}

