import AVFoundation
import Connection
import Foundation

final class SoundPlayer {
    enum SoundType: String {
        case wav
        case mp3
    }

    func play(name: String, type: SoundType = .wav) -> AsyncStream<VectorAudioFrame> {
        .init { continuation in
            guard let url = Bundle.main.url(forResource: name, withExtension: type.rawValue),
                  let file = try? AVAudioFile(forReading: url),
                  let format = AVAudioFormat(
                      commonFormat: .pcmFormatInt16,
                      sampleRate: file.fileFormat.sampleRate,
                      channels: 1,
                      interleaved: false
                  )
            else {
                return
            }

            if let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 1_024) {
                try? file.read(into: buf)
                guard let int16ChannelData = buf.int16ChannelData else {
                    return
                }

                let floatArray = UnsafeBufferPointer(start: int16ChannelData[0], count: Int(buf.frameLength))
                var data = Data()
                for buf in floatArray {
                    data.append(withUnsafeBytes(of: buf) { Data($0) })
                }
                continuation.yield(.init(data: data))
            }
        }
    }
}
