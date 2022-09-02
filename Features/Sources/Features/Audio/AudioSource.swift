import Combine
import AVKit

protocol AudioSource {
    var audioStream: PassthroughSubject<AVAudioPCMBuffer, Never> { get }
    func start()
    func stop()
}
