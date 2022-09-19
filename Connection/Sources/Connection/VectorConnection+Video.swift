import Foundation
import GRPC
import NIO
import SwiftProtobuf

extension VectorConnection: Camera {
    public func requestCameraFeed() throws -> AsyncStream<VectorCameraFrame> {
        .init { continuation in
            typealias CameraFeed = ServerStreamingCall<Anki_Vector_ExternalInterface_CameraFeedRequest,
                Anki_Vector_ExternalInterface_CameraFeedResponse>
            let request = Anki_Vector_ExternalInterface_CameraFeedRequest()
            let stream: CameraFeed = connection.makeServerStreamingCall(
                path: "\(prefixURI)CameraFeed",
                request: request,
                callOptions: callOptions,
                handler: { message in
                    continuation.yield(.init(data: message.data, encoding: message.imageEncoding))
                }
            )

            continuation.onTermination = { _ in
                stream.cancel(promise: nil)
            }
        }
    }
}
