import AVKit
import Combine
import Connection
import Foundation
import Speech

#if os(iOS)
public final class AudioSession: AudioSource {
    private lazy var audioEngine: AVAudioEngine = .init()
    private lazy var audioSession: AVAudioSession = .sharedInstance()

    func feed() throws -> AsyncStream<VectorAudioFrame> {
        .init { continuation in
            try audioSession.setCategory(
                AVAudioSession.Category.record,
                mode: AVAudioSession.Mode.measurement,
                options: AVAudioSession.CategoryOptions.allowAirPlay
            )
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.inputFormat(forBus: 0)
            guard recordingFormat.channelCount > 0 else {
                return
            }
            inputNode.removeTap(onBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1_024, format: recordingFormat) { buffer, _ in
                let data = buffer.data()
                continuation.yield(.init(data: data))
            }

            audioEngine.prepare()
            try audioEngine.start()

            continuation.onTermination = {
                audioEngine.inputNode.removeTap(onBus: 0)
                audioEngine.stop()
            }
        }
    }
}
#endif
