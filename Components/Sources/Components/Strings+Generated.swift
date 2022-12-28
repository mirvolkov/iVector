// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {
  /// apple
  public static let apple = L10n.tr("Localizable", "apple")
  /// BATT
  public static let batt = L10n.tr("Localizable", "BATT")
  /// Camera
  public static let camera = L10n.tr("Localizable", "Camera")
  /// Cancel
  public static let cancel = L10n.tr("Localizable", "Cancel")
  /// cat
  public static let cat = L10n.tr("Localizable", "cat")
  /// cell phone
  public static let cellPhone = L10n.tr("Localizable", "cell phone")
  /// Certificate
  public static let certificate = L10n.tr("Localizable", "Certificate")
  /// clock
  public static let clock = L10n.tr("Localizable", "clock")
  /// Connect
  public static let connect = L10n.tr("Localizable", "Connect")
  /// connection
  public static let connection = L10n.tr("Localizable", "connection")
  /// Control
  public static let control = L10n.tr("Localizable", "Control")
  /// Control Panel
  public static let controlPanel = L10n.tr("Localizable", "Control Panel")
  /// Delete
  public static let delete = L10n.tr("Localizable", "delete")
  /// Error
  public static let error = L10n.tr("Localizable", "error")
  /// Eye color
  public static let eyeColor = L10n.tr("Localizable", "Eye color")
  /// goto
  public static let goto = L10n.tr("Localizable", "goto")
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
  /// OK
  public static let ok = L10n.tr("Localizable", "OK")
  /// person
  public static let person = L10n.tr("Localizable", "person")
  /// PROG
  public static let prog = L10n.tr("Localizable", "PROG")
  /// Program already exists
  public static let programAlreadyExists = L10n.tr("Localizable", "Program already exists")
  /// Programs
  public static let programs = L10n.tr("Localizable", "programs")
  /// Save
  public static let save = L10n.tr("Localizable", "Save")
  /// Say
  public static let say = L10n.tr("Localizable", "Say")
  /// Settings
  public static let settings = L10n.tr("Localizable", "Settings")
  /// sonar
  public static let sonar = L10n.tr("Localizable", "sonar")
  /// stop sign
  public static let stopSign = L10n.tr("Localizable", "stop sign")
  /// Type in message to listen
  public static let typeInMessageToListen = L10n.tr("Localizable", "type in message to listen")
  /// Type in message to say
  public static let typeInMessageToSay = L10n.tr("Localizable", "Type in message to say")
  /// Vector
  public static let vector = L10n.tr("Localizable", "Vector")
  /// View
  public static let view = L10n.tr("Localizable", "view")
  /// vision
  public static let vision = L10n.tr("Localizable", "vision")
  /// Delete program?
  public static let warning = L10n.tr("Localizable", "warning")
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
