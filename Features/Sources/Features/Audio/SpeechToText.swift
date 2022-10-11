import AVKit
import Combine
import Foundation
import OSLog
import Speech

#if os(iOS)
public final class STT: NSObject, SFSpeechRecognizerDelegate {
    typealias SpeechRecognizerCallback = (String?) -> Void

    @Published public var available = false
    @Published public var stt: String?

    public static var shared = STT()

    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let logger = Logger(subsystem: "com.mirfirstsnow.ivector", category: "main")

    fileprivate override init() {}

    public func start(currentLocale: Locale = Locale.current, onEdge: Bool = true) {
        guard recognitionRequest == nil else {
            return
        }

        if let speechRecognizer = SFSpeechRecognizer(locale: currentLocale) {
            speechRecognizer.delegate = self
            speechRecognizer.queue = .init()
            speechRecognizer.supportsOnDeviceRecognition = onEdge
            SFSpeechRecognizer.requestAuthorization { authStatus in
                switch authStatus {
                case .authorized:
                    self.available = true
                    self.startRecording(speechRecognizer: speechRecognizer) { [weak self] text in
                        self?.stt = text
                    }

                default:
                    self.available = false
                }
            }
        } else {
            self.available = false
        }
    }

    private func startRecording(
        speechRecognizer: SFSpeechRecognizer,
        callback: @escaping SpeechRecognizerCallback
    ) {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(
                AVAudioSession.Category.record,
                mode: AVAudioSession.Mode.measurement,
                options: AVAudioSession.CategoryOptions.allowAirPlay
            )
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            logger.error("\(error)")
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode

        guard let recognitionRequest = recognitionRequest else {
            self.available = false
            return
        }

        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer.recognitionTask(
            with: recognitionRequest,
            resultHandler: { result, error in
                guard error == nil else {
                    self.stop()
                    self.startRecording(speechRecognizer: speechRecognizer, callback: callback)
                    return
                }

                if let result = result {
                    self.stt = result.bestTranscription.segments.last?.substring
                    if result.isFinal {
                        self.stop()
                        self.startRecording(speechRecognizer: speechRecognizer, callback: callback)
                    }
                }
            }
        )

        do {
            let recordingFormat = inputNode.inputFormat(forBus: 0)
            guard recordingFormat.channelCount > 0 else {
                return
            }
            inputNode.removeTap(onBus: 0)
            inputNode.installTap(
                onBus: 0,
                bufferSize: 1_024,
                format: recordingFormat
            ) { buffer, _ in
                self.recognitionRequest?.append(buffer)
            }

            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            self.available = false
        }
    }

    private func stop() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        recognitionRequest?.endAudio()
        available = false
    }

    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        self.available = available
    }
}
#endif
