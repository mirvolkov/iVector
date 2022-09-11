import SwiftUI

public struct AudioAccessControl: View {
    public init() {}

    public var body: some View {
        LottieView(name: "mic")
    }
}

struct AudioAccessControlPreview: PreviewProvider {
    static var previews: some View {
        AudioAccessControl()
    }
}
