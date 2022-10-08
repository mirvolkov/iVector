// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {
  /// BATT
  public static let batt = L10n.tr("Localizable", "BATT")
  /// Camera
  public static let camera = L10n.tr("Localizable", "Camera")
  /// Cancel
  public static let cancel = L10n.tr("Localizable", "Cancel")
  /// Certificate
  public static let certificate = L10n.tr("Localizable", "Certificate")
  /// Connect
  public static let connect = L10n.tr("Localizable", "Connect")
  /// connection
  public static let connection = L10n.tr("Localizable", "connection")
  /// Control
  public static let control = L10n.tr("Localizable", "Control")
  /// Control Panel
  public static let controlPanel = L10n.tr("Localizable", "Control Panel")
  /// Eye color
  public static let eyeColor = L10n.tr("Localizable", "Eye color")
  /// GUID
  public static let guid = L10n.tr("Localizable", "GUID")
  /// IP Address
  public static let ipAddress = L10n.tr("Localizable", "IP Address")
  /// listen
  public static let listen = L10n.tr("Localizable", "listen")
  /// Locale
  public static let locale = L10n.tr("Localizable", "Locale")
  /// MEM
  public static let mem = L10n.tr("Localizable", "MEM")
  /// Name the program
  public static let nameTheProgram = L10n.tr("Localizable", "Name the Program")
  /// offline
  public static let offline = L10n.tr("Localizable", "offline")
  /// PROG
  public static let prog = L10n.tr("Localizable", "PROG")
  /// Save
  public static let save = L10n.tr("Localizable", "Save")
  /// Say
  public static let say = L10n.tr("Localizable", "Say")
  /// Settings
  public static let settings = L10n.tr("Localizable", "Settings")
  /// sonar
  public static let sonar = L10n.tr("Localizable", "sonar")
  /// Type in message to say
  public static let typeInMessageToSay = L10n.tr("Localizable", "Type in message to say")
  /// Vector
  public static let vector = L10n.tr("Localizable", "Vector")
  /// vision
  public static let vision = L10n.tr("Localizable", "vision")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
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
