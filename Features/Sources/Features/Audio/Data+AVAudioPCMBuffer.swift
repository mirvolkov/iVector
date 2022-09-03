import AVKit

public extension Data {
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
            audioBuffer.mData?.copyMemory(
                from: baseAddress,
                byteCount: Int(audioBuffer.mDataByteSize)
            )
        }
        return buffer
    }
}

public extension AVAudioPCMBuffer {
    func data(_ channelCount: Int = 1) -> Data {
        let channels = UnsafeBufferPointer(start: self.int16ChannelData, count: channelCount)
        let ch0Data = NSData(
            bytes: channels[0],
            length: Int(self.frameCapacity * self.format.streamDescription.pointee.mBytesPerFrame)
        )
        return ch0Data as Data
    }
}
