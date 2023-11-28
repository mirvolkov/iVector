import SwiftUI

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

public struct HSV {
    static let hRange: ClosedRange<UInt> = 0 ... hMax
    static let svRange: ClosedRange<UInt> = 0 ... svMax
    static let hMax: UInt = 360
    static let svMax: UInt = 100
    static let alphaMax: UInt = 255

    public var hue: UInt
    public var saturation: UInt
    public var brightness: UInt
    public var alpha: UInt

    public var hueComponent: Float {
        Float(hue) / Float(HSV.hMax)
    }

    public var satComponent: Float {
        Float(saturation) / Float(HSV.svMax)
    }
}

public extension Color {
    #if os(macOS)
    var hsv: HSV {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        NSColor(self).getHue(
            &hue,
            saturation: &saturation,
            brightness: &brightness,
            alpha: &alpha
        )

        return .init(
            hue: UInt(lroundf(Float(hue) * Float(HSV.hMax))),
            saturation: UInt(lroundf(Float(saturation) * Float(HSV.svMax))),
            brightness: UInt(lroundf(Float(brightness) * Float(HSV.svMax))),
            alpha: UInt(lroundf(Float(alpha) * Float(HSV.alphaMax)))
        )
    }
    #endif

    #if os(iOS)
    var hsv: HSV {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        guard UIColor(self).getHue(
            &hue,
            saturation: &saturation,
            brightness: &brightness,
            alpha: &alpha
        ) else {
            fatalError("Color conversion failed")
        }

        return .init(hue: UInt(lroundf(Float(hue) * Float(HSV.hMax))),
                     saturation: UInt(lroundf(Float(saturation) * Float(HSV.svMax))),
                     brightness: UInt(lroundf(Float(brightness) * Float(HSV.svMax))),
                     alpha: UInt(lroundf(Float(alpha) * Float(HSV.alphaMax))))
    }
    #endif
}
