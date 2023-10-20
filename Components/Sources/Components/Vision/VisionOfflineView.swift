import SwiftUI

public struct VisionOfflineView: View {
    private let startDate = Date()

    public init() {}

    public var body: some View {
        ZStack(alignment: .center) {
            TimelineView(.periodic(from: startDate, by: 0.1)) { _ in
                Color.black.colorEffect(ShaderLibrary.bundle(.module).noise(
                    .float2(10, 10),
                    .float(startDate.timeIntervalSinceNow)
                ))
            }
        }
    }
}
