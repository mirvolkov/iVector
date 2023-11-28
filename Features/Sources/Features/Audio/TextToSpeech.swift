// swiftlint:disable:next file_header
import AVFoundation
import Connection
import OSLog

public final class TextToSpeech: NSObject, AVSpeechSynthesizerDelegate {
    private let synth = AVSpeechSynthesizer()
    private var lastContinuation: AsyncStream<VectorAudioFrame>.Continuation?
    private let logger = Logger(subsystem: "com.mirfirstsnow.ivector", category: "main")

    public func run(_ stringToSpeak: String, locale: Locale = Locale.current) -> AsyncStream<VectorAudioFrame> {
        let utterance = AVSpeechUtterance(string: stringToSpeak)
        utterance.voice = AVSpeechSynthesisVoice(language: locale.identifier)
        utterance.volume = 1
#if os(iOS)
        synth.usesApplicationAudioSession = false
#endif
        synth.delegate = self
        return .init { continuation in
            self.lastContinuation = continuation
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
            }
        }
    }

    public func say(_ string: String, locale: Locale = Locale.current) {
#if os(iOS)
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.overrideOutputAudioPort(.speaker)
#endif
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: locale.identifier)
        utterance.volume = 1
        self.synth.speak(utterance)
    }

    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        lastContinuation?.finish()
        lastContinuation = nil
    }
}

extension TextToSpeech {
    private func resampleBuffer(inSource: AVAudioPCMBuffer, newSampleRate: Double = 11_025) -> AVAudioPCMBuffer? {
        let outSettings = [
            AVFormatIDKey: kAudioFormatLinearPCM, // kAudioFormatAppleLossless
            AVSampleRateKey: newSampleRate,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMBitDepthKey: 16
        ] as [String: Any]
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

        guard let avConverter else {
            logger.error("AVConverter init failed")
            return nil
        }

        var error: NSError? = nil
        let status = avConverter.convert(to: outBuffer, error: &error, withInputFrom: inputBlock)
        if let error {
            logger.error("\(error)")
            return nil // conversion error
        }

        if status != .haveData {
            logger.error("\(status.rawValue)")
        }

        return outBuffer
    }
}
