// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {
  /// apple
  public static let apple = L10n.tr("Localizable", "apple", fallback: "apple")
  /// BATT
  public static let batt = L10n.tr("Localizable", "BATT", fallback: "BATT")
  /// Camera
  public static let camera = L10n.tr("Localizable", "Camera", fallback: "Camera")
  /// Cancel
  public static let cancel = L10n.tr("Localizable", "Cancel", fallback: "Cancel")
  /// cat
  public static let cat = L10n.tr("Localizable", "cat", fallback: "cat")
  /// cell phone
  public static let cellPhone = L10n.tr("Localizable", "cell phone", fallback: "cell phone")
  /// Certificate
  public static let certificate = L10n.tr("Localizable", "Certificate", fallback: "Certificate")
  /// clock
  public static let clock = L10n.tr("Localizable", "clock", fallback: "clock")
  /// Connect
  public static let connect = L10n.tr("Localizable", "Connect", fallback: "Connect")
  /// Control
  public static let control = L10n.tr("Localizable", "Control", fallback: "Control")
  /// Control Panel
  public static let controlPanel = L10n.tr("Localizable", "Control Panel", fallback: "Control Panel")
  /// Decimation
  public static let decimation = L10n.tr("Localizable", "decimation", fallback: "Decimation")
  /// Delete
  public static let delete = L10n.tr("Localizable", "delete", fallback: "Delete")
  /// Device
  public static let device = L10n.tr("Localizable", "device", fallback: "Device")
  /// Error
  public static let error = L10n.tr("Localizable", "error", fallback: "Error")
  /// Eye color
  public static let eyeColor = L10n.tr("Localizable", "Eye color", fallback: "Eye color")
  /// goto
  public static let goto = L10n.tr("Localizable", "goto", fallback: "goto")
  /// GUID
  public static let guid = L10n.tr("Localizable", "GUID", fallback: "GUID")
  /// IP Address
  public static let ipAddress = L10n.tr("Localizable", "IP Address", fallback: "IP Address")
  /// listen
  public static let listen = L10n.tr("Localizable", "listen", fallback: "listen")
  /// Locale
  public static let locale = L10n.tr("Localizable", "Locale", fallback: "Locale")
  /// MEM
  public static let mem = L10n.tr("Localizable", "MEM", fallback: "MEM")
  /// Name the program
  public static let nameTheProgram = L10n.tr("Localizable", "Name the Program", fallback: "Name the program")
  /// offline
  public static let offline = L10n.tr("Localizable", "offline", fallback: "offline")
  /// OK
  public static let ok = L10n.tr("Localizable", "OK", fallback: "OK")
  /// person
  public static let person = L10n.tr("Localizable", "person", fallback: "person")
  /// PROG
  public static let prog = L10n.tr("Localizable", "PROG", fallback: "PROG")
  /// Program already exists
  public static let programAlreadyExists = L10n.tr("Localizable", "Program already exists", fallback: "Program already exists")
  /// Programs
  public static let programs = L10n.tr("Localizable", "programs", fallback: "Programs")
  /// Rotation
  public static let rotation = L10n.tr("Localizable", "rotation", fallback: "Rotation")
  /// Save
  public static let save = L10n.tr("Localizable", "Save", fallback: "Save")
  /// Say
  public static let say = L10n.tr("Localizable", "Say", fallback: "Say")
  /// Settings
  public static let settings = L10n.tr("Localizable", "Settings", fallback: "Settings")
  /// sonar
  public static let sonar = L10n.tr("Localizable", "sonar", fallback: "sonar")
  /// stop sign
  public static let stopSign = L10n.tr("Localizable", "stop sign", fallback: "stop sign")
  /// Type in message to listen
  public static let typeInMessageToListen = L10n.tr("Localizable", "type in message to listen", fallback: "Type in message to listen")
  /// Type in message to say
  public static let typeInMessageToSay = L10n.tr("Localizable", "Type in message to say", fallback: "Type in message to say")
  /// Vector
  public static let vector = L10n.tr("Localizable", "Vector", fallback: "Vector")
  /// Vector
  public static let vectorConnection = L10n.tr("Localizable", "Vector connection", fallback: "Vector")
  /// View
  public static let view = L10n.tr("Localizable", "view", fallback: "View")
  /// vision
  public static let vision = L10n.tr("Localizable", "vision", fallback: "vision")
  /// Delete program?
  public static let warning = L10n.tr("Localizable", "warning", fallback: "Delete program?")
  /// Websocket
  public static let websocketConnection = L10n.tr("Localizable", "Websocket connection", fallback: "Websocket")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
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
