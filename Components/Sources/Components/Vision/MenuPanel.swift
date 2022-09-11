import SwiftUI

struct VisionMenuPanel: View {
    var body: some View {
        HStack {
            LottieView(name: "cam")
                .frame(width: 32, height: 32)
        }
    }
}
