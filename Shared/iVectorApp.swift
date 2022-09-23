import SwiftUI

@main
struct iVectorApp: App {
    var body: some Scene {
        WindowGroup {
#if os(macOS)
            HomeDesktop()
#endif
            
#if os(iOS)
            if UIDevice.current.userInterfaceIdiom == .pad {
                HomeTablet()
            } else {
                HomePhone()
            }
#endif
        }
    }
}
