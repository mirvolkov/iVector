import SwiftUI
import Components

@main
struct iVectorApp: App {
#if os(iOS)
    @UIApplicationDelegateAdaptor(iVectorAppDelegate.self) private var delegate: iVectorAppDelegate
#elseif os(macOS)
    @NSApplicationDelegateAdaptor(iVectorAppDelegate.self) private var delegate: iVectorAppDelegate
#endif

    let app = AppState()
    
    init() {
        app.bind()
    }

    var body: some Scene {
        WindowGroup {
#if os(macOS)
            HomeDesktop()
                .withErrorHandler()
#endif

#if os(iOS)
            if UIDevice.current.userInterfaceIdiom == .pad {
                HomeTablet()
                    .withErrorHandler()
            } else {
                HomePhone()
                    .withErrorHandler()
            }
#endif
        }
    }
}
