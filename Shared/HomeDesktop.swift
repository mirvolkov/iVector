import Components
import ComposableArchitecture
import Features
import Programmator
import SwiftUI

#if os(macOS)
struct HomeDesktop: View {
    @State private var preferences = false
    @EnvironmentObject private var store: StoreOf<AppFeature>
    @EnvironmentObject private var env: AppEnvironment

    var body: some View {
        NavigationSplitView {
            WithViewStore(store, observe: { $0 }) { viewStore in
                ControlPanelsView(
                    connection: env.connection,
                    settings: env.settings,
                    assembler: env.assembler,
                    onConnect: {
                        viewStore.send(.connect(.connect))
                    }, onDisconnect: {
                        viewStore.send(.connect(.disconnect))
                    })
                    .frame(width: 320, alignment: .top)
                    .padding(0)
            }
        } detail: {
            DetailPanel()
                .frame(height: 620, alignment: .top)
        }
        .toolbar {
            toolbar
        }
        .sheet(isPresented: $preferences) {
            SettingsView(model: .init(), isPresented: $preferences)
        }
        .frame(width: 940, height: 610)
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
        }
        WithViewStore(store, observe: { $0.camera }) { viewStore in
            camButton(online: viewStore.isOnline) {
                viewStore.send(.camera(viewStore.isOnline ? .disconnect : .connect))
            }
        }
        WithViewStore(store, observe: { $0.audio }) { viewStore in
            micButton(online: viewStore.isOnline) {
                viewStore.send(.audio(viewStore.isOnline ? .speechToTextStop : .speechToTextStart))
            }
        }

        settingsButton {
            preferences = true
        }
    }
}
#endif
