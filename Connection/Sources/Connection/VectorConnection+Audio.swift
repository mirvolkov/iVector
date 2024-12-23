import Foundation
import GRPC
import NIO
import SwiftProtobuf

extension VectorConnection: Audio {
    typealias AudioCall = BidirectionalStreamingCall<Anki_Vector_ExternalInterface_ExternalAudioStreamRequest,
                                                     Anki_Vector_ExternalInterface_ExternalAudioStreamResponse>

    typealias AudioFeed = ServerStreamingCall<Anki_Vector_ExternalInterface_AudioFeedRequest,
            Anki_Vector_ExternalInterface_AudioFeedResponse>

    public func requestMicFeed() throws -> AsyncStream<VectorAudioFrame> {
        .init { continuation in
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

    public func playAudio(stream: AsyncStream<VectorAudioFrame>) async throws {
        let accumulator = DataAccumulator()
        let audioCall = prepareAudioCall()
        for await chunk in stream {
            await accumulator.push(chunk.data)
            while await !accumulator.get().isEmpty {
                let data = await accumulator.pop(1_024)
                pushAudioChunk(for: audioCall, data)
            }
        }
        complete(for: audioCall)
    }

    func prepareAudioCall() -> AudioCall {
        let audioCall: AudioCall = connection.makeBidirectionalStreamingCall(
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

        return audioCall
    }

    func pushAudioChunk(for audioCall: AudioCall, _ data: Data) {
        var chunkRequest: Anki_Vector_ExternalInterface_ExternalAudioStreamRequest = .init()
        chunkRequest.audioStreamChunk = .init()
        chunkRequest.audioStreamChunk.audioChunkSamples = data
        chunkRequest.audioStreamChunk.audioChunkSizeBytes = 1_024
        _ = audioCall.sendMessage(chunkRequest)
    }

    func complete(for audioCall: AudioCall) {
        var completeRequest: Anki_Vector_ExternalInterface_ExternalAudioStreamRequest = .init()
        completeRequest.audioStreamComplete = .init()
        _ = audioCall.sendMessage(completeRequest)
    }
}
