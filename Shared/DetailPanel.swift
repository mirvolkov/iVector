import SwiftUI
import Components

struct DetailPanel: View {
    var body: some View {
        VisionView(AppState.instance.connection)
    }
}
