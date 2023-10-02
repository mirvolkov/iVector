// swiftlint:disable force_try
// swiftlint:disable force_unwrapping

import Foundation
import GRPC
import OSLog
import SwiftUI

#if os(iOS)
fileprivate extension CIImage {
    convenience init?(url: URL) {
        guard let data = try? Data(contentsOf: url),
              let image = UIImage(data: data),
              let ciImage = CIImage(image: image)
        else {
            return nil
        }
        self.init(image: image)
    }
}

#elseif os(macOS)
import AppKit
fileprivate extension CIImage {
    convenience init?(url: URL) {
        guard let data = try? Data(contentsOf: url),
              let image = NSImage(data: data)
        else {
            return nil
        }
        self.init(data: data, options: [:])
    }
}
#endif

public final class MockedConnection: Vector {
    public var delegate: ConnectionDelegate?
    private var eventStream: Timer?
    private var visionStream: Timer?
    private let logger = Logger(subsystem: "com.mirfirstsnow.ivector", category: "main")

    public init() {}

    public func requestControl() throws {
        delegate?.keepAlive()
        delegate?.didGrantedControl()
    }

    public func release() throws {
        eventStream?.invalidate()
        visionStream?.invalidate()
        delegate?.didClose()
    }

    public func initSdk() async throws {
        try await Task.sleep(nanoseconds: UInt64(Double.random(in: 0 ... 1) * 1_000_000_000))
    }

    public func requestEventStream() throws {
        let url = Bundle.module.url(forResource: "mock_robot_state", withExtension: "json")!
        let data: Data = try! Data(contentsOf: url)
        eventStream = .scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
            self.delegate?.onRobot(state: try! .init(jsonUTF8Data: data))
        })
    }
}

extension MockedConnection: Audio {
    public func requestMicFeed() throws -> AsyncStream<VectorAudioFrame> {
        .init { continuation in
            continuation.finish()
        }
    }

    public func playAudio(stream: AsyncStream<VectorAudioFrame>) throws {
        print("TTS mocked method. Please note, this doesn't use AVPlayer and produce nothing more than silence")
    }
}

extension MockedConnection: Camera {
    public func requestCameraFeed() throws -> AsyncStream<VectorCameraFrame> {
        .init { continuation in
            let url = Bundle.module.url(forResource: "mock_vision", withExtension: "jpeg")!
            Task {
                await MainActor.run {
                    visionStream = .scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                        if let image = CIImage(url: url) {
                            continuation.yield(.init(image: image))
                        }
                    })
                }
            }
        }
    }
}

extension MockedConnection: Behavior {
    public func say(text: String) async throws {}

    public func setEyeColor(_ hue: Float, _ sat: Float) async throws {
        logger.debug("setEyeColor \(hue) \(sat)")
        try await Task.sleep(nanoseconds: 100_000_000)
    }

    public func oled(with data: Data) async throws {
        logger.debug("OLED")
    }

    public func setHeadAngle(_ angle: Float) async throws {
        logger.debug("setHeadAngle \(angle)")
        try await Task.sleep(nanoseconds: 100_000_000)
    }

    public func lift(_ height: Float) async throws {
        logger.debug("lift \(height)")
        try await Task.sleep(nanoseconds: 100_000_000)
    }

    public func move(_ distance: Float, speed: Float, animate: Bool) async throws {
        logger.debug("move \(distance) \(speed) \(animate)")
        try await Task.sleep(nanoseconds: UInt64(1_000_000_000 * abs(distance) / 100.0))
    }

    public func turn(_ angle: Float, speed: Float, accel: Float, angleTolerance: Float) async throws {
        logger.debug("turn \(angle) \(speed) \(accel) \(angleTolerance)")
        try await Task.sleep(nanoseconds: UInt64(1_000_000_000 * abs(angle) / 100.0))
    }

    public func driveOffCharger() async throws {
        logger.debug("driveOffCharger")
        try await Task.sleep(nanoseconds: UInt64(1_000_000_000 * Float.random(in: 0 ... 1)))
    }

    public func driveOnCharger() async throws {
        logger.debug("driveOnCharger")
        try await Task.sleep(nanoseconds: UInt64(1_000_000_000 * Float.random(in: 0 ... 1)))
    }

    public var battery: VectorBatteryState {
        get async throws {
            [
                VectorBatteryState.charging,
                VectorBatteryState.low,
                VectorBatteryState.full,
                VectorBatteryState.normal
            ].randomElement()!
        }
    }
}

// swiftlint:enable force_try
// swiftlint:enable force_unwrapping
