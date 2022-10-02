import Components
import ComposableArchitecture
import SwiftUI

#if os(macOS)
struct HomeDesktop: View {
    @State private var preferences = false

    var body: some View {
        HSplitView {
            WithViewStore(AppState.store) { viewStore in
                ControlPanelsView(
                    connection: AppState.env.connection,
                    settings: .init(),
                    onConnect: {
                        viewStore.send(.connect(.init()))
                    }, onDisconnect: {
                        viewStore.send(.disconnect)
                    })
                    .frame(width: 320, alignment: .top)
                    .padding(0)
                DetailPanel()
                    .frame(height: 560, alignment: .top)
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
        .frame(width: 940, height: 560)
    }
}
#endif
