import Combine
import Components
import ComposableArchitecture
import Features
import SwiftUI

@main
struct iVectorApp: App {
#if os(iOS)
    @UIApplicationDelegateAdaptor(iVectorAppDelegate.self) private var delegate: iVectorAppDelegate
#elseif os(macOS)
    @NSApplicationDelegateAdaptor(iVectorAppDelegate.self) private var delegate: iVectorAppDelegate
#endif

    let env: AppEnvironment
    let vectorStore: AppFeature.FeatureStore

    init() {
        env = AppEnvironment()
        vectorStore = AppFeature.FeatureStore(
            initialState: .initial,
            reducer: AppFeature(env: env)
        )
    }

    var body: some Scene {
        WindowGroup {
            WithViewStore(vectorStore, observe: { $0 }) { _ in
#if os(macOS)
                HomeDesktop()
#elseif os(iOS)
                if UIDevice.current.userInterfaceIdiom == .pad {
                    HomeTablet()
                } else {
                    HomePhone()
                }
#endif
            }
            .environmentObject(env)
            .environmentObject(vectorStore)
            .withErrorHandler()
        }
    }
}
