import CoreImage
import Foundation
import GRPC
import NIO
import SwiftProtobuf

extension VectorConnection: Camera {
    public func requestCameraFeed() async throws -> AsyncStream<VectorCameraFrame> {
        .init { continuation in
            typealias CameraFeed = ServerStreamingCall<Anki_Vector_ExternalInterface_CameraFeedRequest,
                Anki_Vector_ExternalInterface_CameraFeedResponse>
            let request = Anki_Vector_ExternalInterface_CameraFeedRequest()
            let stream: CameraFeed = connection.makeServerStreamingCall(
                path: "\(prefixURI)CameraFeed",
                request: request,
                callOptions: callOptions,
                handler: { message in
                    if let image = CIImage(data: message.data) {
                        continuation.yield(.init(image: image))
                    }
                }
            )

            continuation.onTermination = { _ in
                stream.cancel(promise: nil)
            }
        }
    }
}
