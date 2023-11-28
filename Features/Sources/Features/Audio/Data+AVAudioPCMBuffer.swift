// swiftlint:disable:next file_header
import AVKit

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
