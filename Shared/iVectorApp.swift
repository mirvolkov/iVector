import SwiftUI
import Components

@main
struct iVectorApp: App {
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
