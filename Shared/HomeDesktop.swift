import Components
import ComposableArchitecture
import SwiftUI

#if os(macOS)
struct HomeDesktop: View {
    @State private var preferences = false
    private let viewStore: ViewStore<VectorAppState, VectorAppAction> = ViewStore(AppState.store)

    var body: some View {
        NavigationView(content: {
            HSplitView {
                ControlPanelsView(
                    connection: AppState.env.connection,
                    settings: .init(),
                    onConnect: {
                        viewStore.send(.connect(.init()))
                    }, onDisconnect: {
                        viewStore.send(.disconnect)
                    })
                    .frame(width: 280)
                    .padding(10)
                DetailPanel()
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
        })
        .frame(width: 940, height: 520)
    }
}
#endif
