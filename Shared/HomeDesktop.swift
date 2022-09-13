import SwiftUI

#if os(macOS)
struct HomeDesktop: View {
    var body: some View {
        HSplitView {
            ControlPanel()
                .frame(width: 320)
            DetailPanel()
                .frame(width: 640, height: 480)
        }
        .ignoresSafeArea()
    }
}
#endif
