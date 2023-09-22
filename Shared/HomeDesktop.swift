import Components
import ComposableArchitecture
import Features
import Programmator
import SwiftUI

#if os(macOS)
struct HomeDesktop: View {
    @State private var preferences = false
    @EnvironmentObject private var store: StoreOf<VectorFeature>
    @EnvironmentObject private var env: VectorAppEnvironment

    var body: some View {
        NavigationSplitView {
            WithViewStore(store, observe: { $0 }) { viewStore in
                ControlPanelsView(
                    connection: env.connection,
                    settings: env.settings,
                    assembler: env.assembler,
                    onConnect: {
                        viewStore.send(.deviceConnect(env.settings))
                    }, onDisconnect: {
                        viewStore.send(.deviceDisconnect)
                    })
                    .frame(width: 320, alignment: .top)
                    .padding(0)
            }
        } detail: {
            DetailPanel()
                .frame(height: 610, alignment: .top)
                .padding(.top, 10)
        }
        .toolbar {
            toolbar
        }
        .sheet(isPresented: $preferences) {
            SettingsView(model: .init(), isPresented: $preferences)
        }
        .frame(width: 940, height: 620)
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
