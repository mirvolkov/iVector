import AVKit
import Combine

struct VectorSource: AudioSource {
    var audioStream: PassthroughSubject<AVAudioPCMBuffer, Never> = .init()

    func start() {}

    func stop() {}
}
