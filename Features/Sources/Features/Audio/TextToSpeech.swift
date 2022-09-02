import AVFoundation

class SpeakerTest: NSObject, AVSpeechSynthesizerDelegate {
    let synth = AVSpeechSynthesizer()

    override init() {
        super.init()
    }

    func resampleBuffer(inSource: AVAudioPCMBuffer, newSampleRate: Double) -> AVAudioPCMBuffer? {
        // resample and convert mono to stereo

        var error: NSError?
        let kChannelStereo = AVAudioChannelCount(1)
        let convertRate = newSampleRate / inSource.format.sampleRate
        let outFrameCount = AVAudioFrameCount(Double(inSource.frameLength) * convertRate)
        let outFormat = AVAudioFormat(standardFormatWithSampleRate: newSampleRate, channels: kChannelStereo)!
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
//            print("\(status): \(status.rawValue)")
            if (status != .haveData) || (error != nil) {
                print("\(status): \(status.rawValue), error: \(String(describing: error))")
                return nil // conversion error
            }
        } else {
            return nil // converter not created
        }
//        print("success!")
        return outBuffer
    }

    func writeToFile(_ stringToSpeak: String, player: @escaping (AVAudioPCMBuffer) -> ()) {
        var output: AVAudioFile?
        let usingSampleRate = 11025.0 // 44100.0
        let outSettings = [
            AVFormatIDKey: kAudioFormatLinearPCM, // kAudioFormatAppleLossless
            AVSampleRateKey: usingSampleRate,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
//            AVLinearPCMBitDepthKey: 16
        ] as [String: Any]

        let utterance = AVSpeechUtterance(string: stringToSpeak)
        utterance.voice = AVSpeechSynthesisVoice(language: "ru-RU")
        utterance.volume = 1

        synth.write(utterance) { (buffer: AVAudioBuffer) in
            guard let pcmBuffer = buffer as? AVAudioPCMBuffer else {
                fatalError("unknown buffer type: \(buffer)")
            }

            print(buffer)
            let outBuffer = self.resampleBuffer(inSource: pcmBuffer, newSampleRate: usingSampleRate)!
            player(outBuffer)
        }
    }

    #if os(iOS)
    func say(_ string: String) {
        DispatchQueue.main.async {
            let audioSession = AVAudioSession.sharedInstance()
            try? audioSession.overrideOutputAudioPort(.speaker)

            let utterance = AVSpeechUtterance(string: string)
            utterance.voice = AVSpeechSynthesisVoice(language: "ru-RU")
            utterance.volume = 1
            self.synth.speak(utterance)
        }
    }
    #endif
}
