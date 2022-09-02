import AVKit
import Combine
import Foundation
import Speech

#if os(iOS)
public final class AudioSession: NSObject {
    private lazy var audioEngine: AVAudioEngine = .init()
    private lazy var audioSession: AVAudioSession = .sharedInstance()
    @Published var audioStream: PassthroughSubject<AVAudioPCMBuffer, Never> = .init()
    
    public func start(currentLocale: Locale = Locale.current, onEdge: Bool = true) {
        do {
            try audioSession.setCategory(
                AVAudioSession.Category.record,
                mode: AVAudioSession.Mode.measurement,
                options: AVAudioSession.CategoryOptions.allowAirPlay
            )
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print(error)
        }
        
        do {
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.inputFormat(forBus: 0)
            guard recordingFormat.channelCount > 0 else { return }
            inputNode.removeTap(onBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
                self?.audioStream.send(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            print(error)
        }
    }
    
    private func stop() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
    }
}
#endif
