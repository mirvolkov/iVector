// swiftlint:disable force_try
// swiftlint:disable force_unwrapping

import Foundation
import GRPC
import SwiftUI

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

    public func playAudio(stream: AsyncStream<VectorAudioFrame>) throws {}
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

    public func setEyeColor(_ hue: Float, _ sat: Float) async throws {}

    public func setHeadAngle(_ angle: Float) async throws {}

    public func lift(_ height: Float) async throws {}

    public func move(_ distance: Float, speed: Float, animate: Bool) async throws {}

    public func turn(_ angle: Float, speed: Float, accel: Float, angleTolerance: Float) async throws {}

    public func driveOffCharger() async throws {}

    public func driveOnCharger() async throws {}

    public var battery: VectorBatteryState {
        get async throws {
            .charging
        }
    }
}
