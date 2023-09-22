import Components
import ComposableArchitecture
import SwiftUI
#if os(iOS)
import UIKit

struct HomeTablet: View {
    @State private var preferences = false
    @EnvironmentObject private var store: StoreOf<VectorFeature>
    @EnvironmentObject private var env: VectorAppEnvironment

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationSplitView {
                ControlPanelsView(
                    connection: env.connection,
                    settings: env.settings,
                    assembler: env.assembler,
                    onConnect: {
                        viewStore.send(.deviceConnect(env.settings))
                    }, onDisconnect: {
                        viewStore.send(.deviceDisconnect)
                    })
                    .frame(width: 320)
                    .navigationTitle(L10n.controlPanel)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        toolbar
                    }

            } detail: {
                ZStack {
                    DetailPanel()
                        .navigationTitle(L10n.camera)
                        .navigationBarTitleDisplayMode(.inline)
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
                if viewStore.socket == .offline {
                    viewStore.send(.socketConnect)
                } else {
                    viewStore.send(.socketDisconnect)
                }
            }
            settingsButton {
                preferences = true
            }
        }
    }
}
#endif
