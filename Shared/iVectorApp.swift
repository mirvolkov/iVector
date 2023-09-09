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
    let store: Store<VectorAppState, VectorAppAction>

    init() {
        env = VectorAppEnvironment()
        store = Store<VectorAppState, VectorAppAction>(
            initialState: .offline,
            reducer: reducer,
            environment: env
        )
    }

    var body: some Scene {
        WindowGroup {
            WithViewStore(store) { _ in
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
            .environmentObject(store)
            .withErrorHandler()
        }.windowResizability(.contentSize)
    }
}
