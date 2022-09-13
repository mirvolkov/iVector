import SwiftUI

@main
struct iVectorApp: App {
    var body: some Scene {
        WindowGroup {
            #if os(macOS)
            HomeDesktop()
            #endif
            
            #if os(iOS)
            HomeTablet()
            #endif
        }
    }
}
