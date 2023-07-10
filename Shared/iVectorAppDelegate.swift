class iVectorAppDelegate: NSObject {}

#if canImport(UIKit)
import Intents
import UIKit

extension iVectorAppDelegate: UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // Record the device token.
    }

    func application(_ application: UIApplication, handle intent: INIntent, completionHandler: @escaping (INIntentResponse) -> Void) {
        let response = INPlayMediaIntentResponse(code: .success, userActivity: nil)
        completionHandler(response)
    }

    func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        print(userActivityType)
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        print("open url \(url)")
        return true
    }
}
#endif

#if canImport(AppKit)
import AppKit

extension iVectorAppDelegate: NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
#endif
