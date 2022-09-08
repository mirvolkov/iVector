// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit.NSFont
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIFont
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "FontConvertible.Font", message: "This typealias will be removed in SwiftGen 7.0")
public typealias Font = FontConvertible.Font

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Fonts

// swiftlint:disable identifier_name line_length type_body_length
public enum FontFamily {
  public enum RobotoMono {
    public static let bold = FontConvertible(name: "RobotoMono-Bold", family: "Roboto Mono", path: "RobotoMono-Bold.ttf")
    public static let boldItalic = FontConvertible(name: "RobotoMono-BoldItalic", family: "Roboto Mono", path: "RobotoMono-BoldItalic.ttf")
    public static let italic = FontConvertible(name: "RobotoMono-Italic", family: "Roboto Mono", path: "RobotoMono-Italic.ttf")
    public static let light = FontConvertible(name: "RobotoMono-Light", family: "Roboto Mono", path: "RobotoMono-Light.ttf")
    public static let lightItalic = FontConvertible(name: "RobotoMono-LightItalic", family: "Roboto Mono", path: "RobotoMono-LightItalic.ttf")
    public static let medium = FontConvertible(name: "RobotoMono-Medium", family: "Roboto Mono", path: "RobotoMono-Medium.ttf")
    public static let mediumItalic = FontConvertible(name: "RobotoMono-MediumItalic", family: "Roboto Mono", path: "RobotoMono-MediumItalic.ttf")
    public static let regular = FontConvertible(name: "RobotoMono-Regular", family: "Roboto Mono", path: "RobotoMono-Regular.ttf")
    public static let thin = FontConvertible(name: "RobotoMono-Thin", family: "Roboto Mono", path: "RobotoMono-Thin.ttf")
    public static let thinItalic = FontConvertible(name: "RobotoMono-ThinItalic", family: "Roboto Mono", path: "RobotoMono-ThinItalic.ttf")
    public static let all: [FontConvertible] = [bold, boldItalic, italic, light, lightItalic, medium, mediumItalic, regular, thin, thinItalic]
  }
  public static let allCustomFonts: [FontConvertible] = [RobotoMono.all].flatMap { $0 }
  public static func registerAllCustomFonts() {
    allCustomFonts.forEach { $0.register() }
  }
}
// swiftlint:enable identifier_name line_length type_body_length

// MARK: - Implementation Details

public struct FontConvertible {
  public let name: String
  public let family: String
  public let path: String

  #if os(macOS)
  public typealias Font = NSFont
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Font = UIFont
  #endif

  public func font(size: CGFloat) -> Font {
    guard let font = Font(font: self, size: size) else {
      fatalError("Unable to initialize font '\(name)' (\(family))")
    }
    return font
  }

  public func register() {
    // swiftlint:disable:next conditional_returns_on_newline
    guard let url = url else { return }
    CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
  }

  fileprivate var url: URL? {
    // swiftlint:disable:next implicit_return
    return BundleToken.bundle.url(forResource: path, withExtension: nil)
  }
}

public extension FontConvertible.Font {
  convenience init?(font: FontConvertible, size: CGFloat) {
    #if os(iOS) || os(tvOS) || os(watchOS)
    if !UIFont.fontNames(forFamilyName: font.family).contains(font.name) {
      font.register()
    }
    #elseif os(macOS)
    if let url = font.url, CTFontManagerGetScopeForURL(url as CFURL) == .none {
      font.register()
    }
    #endif

    self.init(name: font.name, size: size)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
