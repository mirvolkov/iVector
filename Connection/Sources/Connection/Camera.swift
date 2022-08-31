import Foundation

public struct VectorCameraFrame {
    public let data: Data
    public let encoding: Anki_Vector_ExternalInterface_ImageChunk.ImageEncoding
}

public protocol Camera {
    /// Request Vector's camera feed
    /// - Returns AsyncStream type with frame
    /// - Throws error if request failed
    func requestCameraFeed() throws -> AsyncStream<VectorCameraFrame>
}
