import Components
import SwiftUI

#if os(macOS)
struct HomeDesktop: View {
    var body: some View {
        HSplitView {
            ControlPanelsView(connection: AppState.instance.connection, settings: AppState.instance.settings)
                .frame(width: 280)
                .padding(10)
            DetailPanel()
                .padding(0)
                .frame(width: 640)
        }
        .frame(height: 520)
    }
}
#endif
