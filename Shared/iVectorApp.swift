import Combine
import Components
import ComposableArchitecture
import Features
import Observation
import SwiftUI

@main
struct iVectorApp: App {
    @MainActor class AppViewModel {
        let env: AppEnvironment = .init()
        lazy var store: Store<AppFeature.State, AppFeature.Action> = AppFeature.FeatureStore(
            initialState: .initial,
            reducer: { AppFeature(env: env) }
        )
    }

#if os(iOS)
    @UIApplicationDelegateAdaptor(iVectorAppDelegate.self) private var delegate: iVectorAppDelegate
#elseif os(macOS)
    @NSApplicationDelegateAdaptor(iVectorAppDelegate.self) private var delegate: iVectorAppDelegate
#endif

    @State var appViewModel: AppViewModel = .init()

    var body: some Scene {
        WindowGroup {
            WithViewStore(appViewModel.store, observe: { $0 }) { viewStore in
                home
                    .environmentObject(appViewModel.env)
                    .environmentObject(appViewModel.store)
                    .withErrorHandler()
                    .onAppear {
                        appViewModel.env.connection.hub.bind(appViewModel.env.settings)
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
