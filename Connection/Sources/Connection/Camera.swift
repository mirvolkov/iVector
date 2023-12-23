import Foundation
import CoreImage

public struct VectorCameraFrame {
    public let image: CIImage
}

public struct VectorCameraSettings {
    /// Rotation angle in degrees
    public let rotation: Int
    public let deviceID: String?

    public init(rotation: Int, deviceID: String?) {
        self.rotation = rotation
        self.deviceID = deviceID
    }

    public static var `default`: Self {
        .init(rotation: 0, deviceID: nil)
    }
}

public protocol Camera {
    /// Request Vector's camera feed
    /// - Returns AsyncStream type with frame
    /// - Throws error if request failed
    func requestCameraFeed(with settings: VectorCameraSettings) async throws -> AsyncStream<VectorCameraFrame>
}
