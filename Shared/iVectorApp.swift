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
            WithViewStore(vectorStore, observe: { $0 }) { viewStore in
                home
                    .environmentObject(env)
                    .environmentObject(vectorStore)
                    .withErrorHandler()
                    .onAppear {
                        env.connection.hub.bind()
                        viewStore.send(.audio(.speechToTextStart))
                        viewStore.send(.connect(.connect))
                        viewStore.send(.socket(.connect))
                    }
            }
        }
    }

    @ViewBuilder
    var home: some View {
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
}
