import SwiftUI
import Components

struct DetailPanel: View {
    var body: some View {
        VisionView(connection: AppState.instance.connection, vision: AppState.instance.vision)
    }
}
