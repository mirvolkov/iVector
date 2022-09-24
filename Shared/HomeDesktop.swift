import Components
import SwiftUI

#if os(macOS)
struct HomeDesktop: View {
    @State var preferences = false

    var body: some View {
        NavigationView(content: {
            HSplitView {
                ControlPanelsView(connection: AppState.instance.connection, settings: AppState.instance.settings)
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
                SettingsView(model: AppState.instance.settings, isPresented: $preferences)
            }
        })
        .frame(width: 940, height: 520)
    }
}
#endif
