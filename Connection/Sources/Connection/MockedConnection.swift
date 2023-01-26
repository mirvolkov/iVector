// swiftlint:disable force_try
// swiftlint:disable force_unwrapping

import Foundation
import GRPC
import SwiftUI
import OSLog

#if os(macOS)
import AppKit

func image(url: URL) -> Data {
    let image = NSImage(contentsOf: url)!
    let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
    let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
    return bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!
}

#elseif os(iOS)
import UIKit

func image(url: URL) -> Data {
    let image = UIImage(data: try! .init(contentsOf: url))!
    return image.jpegData(compressionQuality: 0.75)!
}

#endif

public final class MockedConnection: Connection {
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
            let data: Data = image(url: url)
            Task {
                await MainActor.run {
                    visionStream = .scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                        continuation.yield(.init(data: data, encoding: .jpegColor))
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
        try await Task.sleep(nanoseconds: UInt64(1_000_000_000 * Float.random(in: 0...1)))
    }

    public func driveOnCharger() async throws {
        logger.debug("driveOnCharger")
        try await Task.sleep(nanoseconds: UInt64(1_000_000_000 * Float.random(in: 0...1)))
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
