import AVFoundation
import Connection

public final class TextToSpeech: NSObject, AVSpeechSynthesizerDelegate {
    let synth = AVSpeechSynthesizer()

    func resampleBuffer(inSource: AVAudioPCMBuffer, newSampleRate: Double = 11025.0) -> AVAudioPCMBuffer? {
        let outSettings = [
            AVFormatIDKey: kAudioFormatLinearPCM, // kAudioFormatAppleLossless
            AVSampleRateKey: 11_025.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMBitDepthKey: 16
        ] as [String: Any]

        var error: NSError?
        let convertRate = newSampleRate / inSource.format.sampleRate
        let outFrameCount = AVAudioFrameCount(Double(inSource.frameLength) * convertRate)
        let outFormat = AVAudioFormat(settings: outSettings)!
        let avConverter = AVAudioConverter(from: inSource.format, to: outFormat)
        let outBuffer = AVAudioPCMBuffer(pcmFormat: outFormat, frameCapacity: outFrameCount)!
        let inputBlock: AVAudioConverterInputBlock = { _, outStatus -> AVAudioBuffer? in
            outStatus.pointee = AVAudioConverterInputStatus.haveData // very important, must have
            let audioBuffer: AVAudioBuffer = inSource
            return audioBuffer
        }
        avConverter?.sampleRateConverterAlgorithm = AVSampleRateConverterAlgorithm_Mastering
        avConverter?.sampleRateConverterQuality = .min

        if let converter = avConverter {
            let status = converter.convert(to: outBuffer, error: &error, withInputFrom: inputBlock)
            if (status != .haveData) || (error != nil) {
                print("\(status): \(status.rawValue), error: \(String(describing: error))")
                return nil // conversion error
            }
        } else {
            return nil
        }

        return outBuffer
    }

    public func writeToFile(_ stringToSpeak: String, language: String = "ru-RU") -> AsyncStream<AudioFrame> {
        let utterance = AVSpeechUtterance(string: stringToSpeak)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.volume = 1
        return .init { continuation in
            synth.write(utterance) { (buffer: AVAudioBuffer) in
                guard let pcmBuffer = buffer as? AVAudioPCMBuffer else {
                    continuation.finish()
                    return
                }
                guard let resampled = self.resampleBuffer(inSource: pcmBuffer) else {
                    continuation.finish()
                    return
                }

                continuation.yield(.init(data: resampled.data()))
                continuation.finish()
            }
        }
    }

    #if os(iOS)
    func say(_ string: String, language: String = "ru-RU") {
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.overrideOutputAudioPort(.speaker)
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.volume = 1
        self.synth.speak(utterance)
    }
    #endif
}
