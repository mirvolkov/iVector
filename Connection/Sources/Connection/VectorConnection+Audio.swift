import GRPC
import NIO
import SwiftProtobuf
import Foundation

extension VectorConnection: Audio {
    public func requestMicFeed() throws -> AsyncStream<VectorAudioFrame> {
        .init { continuation in
            typealias AudioFeed = ServerStreamingCall<Anki_Vector_ExternalInterface_AudioFeedRequest,
                Anki_Vector_ExternalInterface_AudioFeedResponse>
            let stream: AudioFeed = connection.makeServerStreamingCall(
                path: "\(prefixURI)AudioFeed",
                request: .init(),
                callOptions: callOptions,
                handler: { message in
                    continuation.yield(.init(
                        data: message.signalPower,
                        timestamp: message.robotTimeStamp,
                        direction: message.sourceDirection
                    ))
                }
            )

            continuation.onTermination = { _ in
                stream.cancel(promise: nil)
            }
        }
    }

    public func playAudio(stream: AsyncStream<VectorAudioFrame>) throws {
        let accumulator = DataAccumulator()
        let audioCall: BidirectionalStreamingCall<Anki_Vector_ExternalInterface_ExternalAudioStreamRequest,
            Anki_Vector_ExternalInterface_ExternalAudioStreamResponse> = connection.makeBidirectionalStreamingCall(
            path: "\(prefixURI)ExternalAudioStreamPlayback",
            callOptions: callOptions,
            handler: { message in
                Self.log("Audio stream callback \(message)")
            }
        )

        var prepareRequest: Anki_Vector_ExternalInterface_ExternalAudioStreamRequest = .init()
        prepareRequest.audioStreamPrepare = .init()
        prepareRequest.audioStreamPrepare.audioVolume = 100
        prepareRequest.audioStreamPrepare.audioFrameRate = 11_025
        _ = audioCall.sendMessage(prepareRequest)

        Task {
            for await chunk in stream {
                await accumulator.push(chunk.data)
                while await !accumulator.get().isEmpty {
                    var chunkRequest: Anki_Vector_ExternalInterface_ExternalAudioStreamRequest = .init()
                    chunkRequest.audioStreamChunk = .init()
                    chunkRequest.audioStreamChunk.audioChunkSamples = await accumulator.pop(1_024)
                    chunkRequest.audioStreamChunk.audioChunkSizeBytes = 1_024
                    _ = audioCall.sendMessage(chunkRequest)
                }
            }

            var completeRequest: Anki_Vector_ExternalInterface_ExternalAudioStreamRequest = .init()
            completeRequest.audioStreamComplete = .init()
            _ = audioCall.sendMessage(completeRequest)
        }
    }
}
