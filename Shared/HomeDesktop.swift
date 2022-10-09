import Components
import ComposableArchitecture
import SwiftUI
import Programmator

#if os(macOS)
struct HomeDesktop: View {
    @State private var preferences = false

    var body: some View {
        HSplitView {
            WithViewStore(AppState.store) { viewStore in
                ControlPanelsView(
                    connection: AppState.env.connection,
                    settings: AppState.env.settings,
                    assembler: AppState.env.assembler,
                    onConnect: {
                        viewStore.send(.connect(AppState.env.settings))
                    }, onDisconnect: {
                        viewStore.send(.disconnect)
                    })
                    .frame(width: 320, alignment: .top)
                    .padding(0)
                DetailPanel()
                    .frame(height: 600, alignment: .top)
                    .padding(0)
            }
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
        .frame(width: 940, height: 600)
    }
}
#endif
