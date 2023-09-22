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

    let env: VectorAppEnvironment
    let vectorStore: VectorFeature.FeatureStore

    init() {
        env = VectorAppEnvironment()
        vectorStore = VectorFeature.FeatureStore(
            initialState: .init(),
            reducer: VectorFeature(env: env)
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
