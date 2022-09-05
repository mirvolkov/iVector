import AVKit
import Combine
import Foundation
import Speech

public final class SpeechToText: NSObject, SFSpeechRecognizerDelegate {
    typealias SpeechRecognizerCallback = (String?) -> Void

    @Published public var available = false
    @Published public var stt: String?

    private var recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    private var recognitionTask: SFSpeechRecognitionTask?
    private let source: AudioSource

    private let audioFormat = AVAudioFormat(
        commonFormat: .pcmFormatInt16,
        sampleRate: 16_000,
        channels: 1,
        interleaved: true
    )!

    required init(with source: AudioSource) {
        self.source = source
    }

    public func start(currentLocale: Locale = Locale.current, onEdge: Bool = true) {
        if let speechRecognizer = SFSpeechRecognizer(locale: currentLocale) {
            speechRecognizer.delegate = self
            speechRecognizer.queue = .init()
            speechRecognizer.supportsOnDeviceRecognition = onEdge
            SFSpeechRecognizer.requestAuthorization { authStatus in
                switch authStatus {
                case .authorized:
                    self.available = true
                    self.startRecording(speechRecognizer: speechRecognizer)

                default:
                    self.available = false
                }
            }
        } else {
            available = false
        }
    }

    private func startRecording(speechRecognizer: SFSpeechRecognizer) {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }

        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { result, error in
            guard error == nil else {
                self.stop()
                self.startRecording(speechRecognizer: speechRecognizer)
                return
            }

            if let result = result, result.isFinal {
                self.stop()
                self.startRecording(speechRecognizer: speechRecognizer)
            }
        })
    }

    public func append(_ data: Data) {
        guard let buffer = data.pcmBuffer(format: audioFormat) else {
            debugPrint("Cannot convert buffer from Data")
            return
        }
        recognitionRequest.append(buffer)
    }

    public func append(_ buffer: AVAudioPCMBuffer) {
        recognitionRequest.append(buffer)
    }

    private func stop() {
        recognitionRequest.endAudio()
        available = false
    }

    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        self.available = available
    }
}
