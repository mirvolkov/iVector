// swiftlint:disable:next file_header
import AVKit
import Combine
import Foundation
import OSLog
import Speech
import Connection

public protocol SpeechRecognizer {
    typealias Callback = (String) -> Void

    var available: PassthroughSubject<Bool, Never> { get }
    var text: PassthroughSubject<String, Never> { get }

    func start(currentLocale: Locale, onEdge: Bool)
}

public final class SpeechToText: NSObject, SFSpeechRecognizerDelegate, SpeechRecognizer, @unchecked Sendable {
    public let available: PassthroughSubject<Bool, Never> = .init()
    public let text: PassthroughSubject<String, Never> = .init()

    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let logger = Logger(subsystem: "com.mirfirstsnow.ivector", category: "main")
    private lazy var inputNode = audioEngine.inputNode

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
                    self.available.send(true)
                    self.startRecording(speechRecognizer: speechRecognizer) { [weak self] text in
                        self?.text.send(text)
                    }

                default:
                    self.available.send(false)
                }
            }
        } else {
            self.available.send(false)
        }
    }

    private func runloop() {
        do {
            let bus = 1
            let recordingFormat = inputNode.inputFormat(forBus: bus)
            guard recordingFormat.channelCount > 0 else {
                self.available.send(false)
                return
            }

            inputNode.removeTap(onBus: bus)
            inputNode.installTap(
                onBus: bus,
                bufferSize: 1_024,
                format: recordingFormat
            ) { buffer, _ in
                self.recognitionRequest?.append(buffer)
            }

#if os(iOS)
            audioEngine.prepare()
#else
            audioEngine.connect(inputNode, to: audioEngine.mainMixerNode, format: recordingFormat)
#endif
            try audioEngine.start()
        } catch {
            logger.error("\(error)")
            self.available.send(false)
        }
    }

    private func startRecording(
        speechRecognizer: SFSpeechRecognizer,
        callback: @escaping SpeechRecognizer.Callback
    ) {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
//#if os(iOS)
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            try audioSession.setCategory(
//                AVAudioSession.Category.record,
//                mode: AVAudioSession.Mode.measurement,
//                options: AVAudioSession.CategoryOptions.allowAirPlay
//            )
//            try audioSession.setMode(AVAudioSession.Mode.measurement)
//            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
//        } catch {
//            logger.error("\(error)")
//        }
//#endif
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            self.available.send(false)
            return
        }

        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer.recognitionTask(
            with: recognitionRequest,
            resultHandler: { result, error in
                guard error == nil && result?.isFinal == false else {
                    self.stop()
                    self.startRecording(speechRecognizer: speechRecognizer, callback: callback)
                    return
                }

                if let result = result?.bestTranscription.segments.map({ $0.substring }).last {
                    self.text.send(result)
                }
            }
        )

        runloop()
    }

    public func stop() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }

    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        self.available.send(available)
    }
}
