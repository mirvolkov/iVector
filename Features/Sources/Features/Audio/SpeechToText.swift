import AVKit
import Combine
import Foundation
import Speech

public final class STT: NSObject, SFSpeechRecognizerDelegate {
    typealias SpeechRecognizerCallback = (String?) -> ()
    
    @Published public var available: Bool = false
    @Published public var stt: String? = nil
    public static var shared: STT = .init()
    
    private var recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    private var recognitionTask: SFSpeechRecognitionTask?
    
    override fileprivate init() {}
    
    public func start(currentLocale: Locale = Locale.current, onEdge: Bool = true) {
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
            available = false
        }
    }

    let playerNode = AVAudioPlayerNode()
    private func startRecording(speechRecognizer: SFSpeechRecognizer, callback: @escaping SpeechRecognizerCallback) {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
  
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { result, error in
            guard error == nil else {
                self.stop()
                self.startRecording(speechRecognizer: speechRecognizer, callback: callback)
                return
            }
            
            if let result = result {
                DispatchQueue.main.async {
                    callback(result.bestTranscription.segments.last?.substring)
                }
            
                if result.isFinal {
                    self.stop()
                    self.startRecording(speechRecognizer: speechRecognizer, callback: callback)
                }
            }
        })
    }
    
    let audioFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 16000, channels: 1, interleaved: true)!
    public func append(_ data: Data) {
        guard let buffer = data.pcmBuffer(format: audioFormat) else {
            debugPrint("Cannot convert buffer from Data")
            return
        }
        recognitionRequest.append(buffer)
//        playerNode.scheduleBuffer(buffer)
    }
    
    private func stop() {
//        audioEngine.inputNode.removeTap(onBus: 0)
//        audioEngine.stop()
        recognitionRequest.endAudio()
        available = false
    }
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        self.available = available
    }
}

private extension Data {
    func pcmBuffer(format: AVAudioFormat) -> AVAudioPCMBuffer? {
        let streamDesc = format.streamDescription.pointee
        let frameCapacity = UInt32(count) / streamDesc.mBytesPerFrame
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCapacity) else { return nil }
        buffer.frameLength = buffer.frameCapacity
        let audioBuffer = buffer.audioBufferList.pointee.mBuffers
        withUnsafeBytes { addr in
            guard let baseAddress = addr.baseAddress else {
                return
            }
            audioBuffer.mData?.copyMemory(from: baseAddress, byteCount: Int(audioBuffer.mDataByteSize))
        }
        return buffer
    }
}
