import Components
import ComposableArchitecture
import Features
import Programmator
import SwiftUI

#if os(macOS)
struct HomeDesktop: View {
    @State private var preferences = false
    @EnvironmentObject private var store: VectorStore
    @EnvironmentObject private var env: VectorAppEnvironment

    var body: some View {
        NavigationSplitView {
            WithViewStore(store) { viewStore in
                ControlPanelsView(
                    connection: env.connection,
                    settings: env.settings,
                    assembler: env.assembler,
                    onConnect: {
                        viewStore.send(.connect(env.settings))
                    }, onDisconnect: {
                        viewStore.send(.disconnect)
                    })
                    .frame(width: 320, alignment: .top)
                    .padding(0)
            }
        } detail: {
            DetailPanel()
                .frame(height: 610, alignment: .top)
                .padding(0)
        }
        .toolbar {
            Button {
                preferences = true
            } label: {
                Image(systemName: "gear")
            }.buttonStyle(.plain)
        }
        .sheet(isPresented: $preferences) {
            SettingsView(model: .init(), isPresented: $preferences)
        }
        .frame(width: 940, height: 610)
    }
}
#endif
