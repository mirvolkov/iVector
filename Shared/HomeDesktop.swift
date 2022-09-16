import SwiftUI
import Components

#if os(macOS)
struct HomeDesktop: View {
    var body: some View {
        HSplitView {
            ControlPanelsView(connection: AppState.instance.connection, settings: AppState.instance.settings)
                .frame(width: 320)
            DetailPanel()
                .frame(width: 640, height: 560)
        }
        .ignoresSafeArea()
    }
}
#endif
