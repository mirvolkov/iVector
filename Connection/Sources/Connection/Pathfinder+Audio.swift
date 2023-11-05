// swiftlint:disable:next file_header
import AVFAudio
import Foundation
import OSLog

extension PathfinderConnection: Audio {
    public func requestMicFeed() throws -> AsyncStream<VectorAudioFrame> {
        throw PathfinderError.micFailed
    }

    public func playAudio(stream: AsyncStream<VectorAudioFrame>) async throws {
        try await playStream(stream)
    }
}

public extension Audio {
    // swiftlint:disable:next function_body_length
    func playStream(_ stream: AsyncStream<VectorAudioFrame>) async throws {
        var data: Data = .init()
        let sampleRate: Double = 11_025
        let logger = Logger(subsystem: "com.mirfirstsnow.ivector", category: "pathfinder")

        // make sure data is erased. data can contains a lot
        defer {
            data.removeAll()
        }

        // accumulate all samples into one data buffer
        for await buffer in stream {
            data.append(buffer.data)
        }

        // initiate audio engine
        let audioEngine = AudioEngine.shared
        let audioFilePlayer = AVAudioPlayerNode()

        // attach player into mixer
        let mainMixer = audioEngine.mainMixerNode
        audioEngine.attach(audioFilePlayer)

        // define in and out formates. REASON: audio player doesn't work with Int16. It must be converted into float32
        guard let playFormat = AVAudioFormat(
            commonFormat: .pcmFormatInt16,
            sampleRate: Double(sampleRate),
            channels: 1,
            interleaved: true
        ) else {
            throw PathfinderError.speakerFailed
        }

        guard let outputFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: Double(sampleRate),
            channels: 1,
            interleaved: true
        ) else {
            throw PathfinderError.speakerFailed
        }

        // audio converter
        guard let converter = AVAudioConverter(from: playFormat, to: outputFormat) else {
            throw PathfinderError.speakerFailed
        }

        // get buffer from data
        if let audioBufferIn = data.pcmBuffer(format: playFormat) {
            let convertRate = sampleRate / audioBufferIn.format.sampleRate
            let outFrameCount = AVAudioFrameCount(Double(audioBufferIn.frameLength) * convertRate)
            guard let audioBufferOut = AVAudioPCMBuffer(pcmFormat: outputFormat, frameCapacity: outFrameCount) else {
                throw PathfinderError.speakerFailed
            }

            var error: NSError?
            converter.convert(to: audioBufferOut, error: &error) { _, outStatus in
                outStatus.pointee = .haveData
                let audioBuffer: AVAudioBuffer = audioBufferIn
                return audioBuffer
            }

            if let converterError = error {
                logger.error("\(converterError.description)")
            }

            // play converted data
            audioEngine.connect(audioFilePlayer, to: mainMixer, format: outputFormat)
            try audioEngine.start()
            audioFilePlayer.play()
            await audioFilePlayer.scheduleBuffer(audioBufferOut)
        }
    }
}

public extension Data {
    func pcmBuffer(format: AVAudioFormat) -> AVAudioPCMBuffer? {
        let streamDesc = format.streamDescription.pointee
        let frameCapacity = UInt32(count) / streamDesc.mBytesPerFrame

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCapacity) else {
            return nil
        }

        buffer.frameLength = buffer.frameCapacity
        let audioBuffer = buffer.audioBufferList.pointee.mBuffers
        withUnsafeBytes { addr in
            guard let baseAddress = addr.baseAddress else {
                return
            }
            audioBuffer.mData?.copyMemory(
                from: baseAddress,
                byteCount: Int(audioBuffer.mDataByteSize)
            )
        }

        return buffer
    }
}

public enum AudioEngine {
    public static let shared = AVAudioEngine()
}
