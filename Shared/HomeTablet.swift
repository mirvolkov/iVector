import Components
import ComposableArchitecture
import SwiftUI
#if os(iOS)
import UIKit

struct HomeTablet: View {
    @State private var preferences = false
    @EnvironmentObject private var store: StoreOf<AppFeature>
    @EnvironmentObject private var env: AppEnvironment

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationSplitView {
                ControlPanelsView(
                    connection: env.connection,
                    settings: env.settings,
                    assembler: env.assembler,
                    onConnect: {
                        viewStore.send(.connect(.connect))
                    }, onDisconnect: {
                        viewStore.send(.connect(.disconnect))
                    })
                    .frame(width: 320)
                    .navigationTitle(L10n.controlPanel)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        settingsButton {
                            preferences = true
                        }
                    }

            } detail: {
                ZStack {
                    DetailPanel()
                        .navigationTitle(L10n.camera)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            toolbar
                        }
                }
            }
            .sheet(isPresented: $preferences) {
                SettingsView(model: .init(), isPresented: $preferences)
            }
            .onAppear {
                if #available(iOS 15.0, *) {
                    let navigationBarAppearance = UINavigationBarAppearance()
                    navigationBarAppearance.backgroundColor = .systemBackground
                    navigationBarAppearance.titleTextAttributes = [.font: FontFamily.RobotoMono.regular.font(size: 16) as CTFont]
                    UINavigationBar.appearance().standardAppearance = navigationBarAppearance
                    UINavigationBar.appearance().compactAppearance = navigationBarAppearance
                    UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
                }
            }
            .ignoresSafeArea()
        }
    }

    @ViewBuilder
    private var toolbar: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            socketButton(online: viewStore.socket == .online) {
                viewStore.send(.socket(.connect))
            }
            motionButton(online: viewStore.motion == .online) {
                viewStore.send(.motion(.connect))
            }
            camButton(online: viewStore.camera.isOnline) {
                viewStore.send(.camera(.connect))
            }
        }
    }
}
#endif
