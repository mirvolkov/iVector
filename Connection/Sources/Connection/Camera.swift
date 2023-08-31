import Foundation
import CoreImage

public struct VectorCameraFrame {
    public let image: CIImage
}

public protocol Camera {
    /// Request Vector's camera feed
    /// - Returns AsyncStream type with frame
    /// - Throws error if request failed
    func requestCameraFeed() throws -> AsyncStream<VectorCameraFrame>
}
