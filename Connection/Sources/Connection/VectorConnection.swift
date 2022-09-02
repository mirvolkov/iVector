import GRPC
import Logging
import NIO
import NIOHPACK
import NIOHTTP1
import NIOHTTP2
import NIOSSL
import SwiftProtobuf

import Foundation
import Network
import NIOTransportServices
import os.log
import Security

public final class VectorConnection: Connection {
    private let prefixURI = "/Anki.Vector.external_interface.ExternalInterface/"
    private let guid: String = "uOXbJIpdSiGgM6SgSoYFUA=="
    private lazy var callOptions: CallOptions = .init(customMetadata: headers)
    private lazy var headers: HPACKHeaders = ["authorization": "Bearer \(guid)"]
    private let logger = Logger(subsystem: "com.mirfirstsnow.ivector", category: "main")
    private let connection: ClientConnection
    private var requestStream: ControlRequestStream?
    private static let firstSDKTag: Int32 = 2000001
    public weak var delegate: ConnectionDelegate?
    
    public init(with ip: String, port: Int) {
        logger.debug("Vector connection init")
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let certificatePath = Bundle.module.path(forResource: "Vector-E1B6-003099a9", ofType: "cert")!
        var tls = TLSConfiguration.makeClientConfiguration()
        tls.trustRoots = .file(certificatePath)
        tls.certificateVerification = .noHostnameVerification
        tls.applicationProtocols = ["h2"]

        let tls1 = ClientConnection.Configuration.TLS(configuration: tls)
        var configuration = ClientConnection.Configuration(
            target: .hostAndPort(ip, port),
            eventLoopGroup: group,
            errorDelegate: nil,
            connectivityStateDelegate: nil,
            tls: tls1
        )
        
        connection = ClientConnection(configuration: configuration)
        configuration.errorDelegate = self
        configuration.connectivityStateDelegate = self
    }
    
    deinit {
        log("Vector connection deinit")
        try? connection.close().wait()
    }
    
    public func initSdk() async throws {
        var sdkInitRequest = Anki_Vector_ExternalInterface_SDKInitializationRequest()
        sdkInitRequest.sdkModuleVersion = "0.6.0"
        sdkInitRequest.osVersion = "macOS-12.4-arm64-arm-64bit"
        sdkInitRequest.pythonVersion = "3.8.9"
        sdkInitRequest.cpuVersion = "arm64"
        sdkInitRequest.pythonImplementation = "CPython"
        
        let sdk: UnaryCall<Anki_Vector_ExternalInterface_SDKInitializationRequest,
            Anki_Vector_ExternalInterface_SDKInitializationResponse> = connection.makeUnaryCall(
            path: "\(prefixURI)SDKInitialization",
            request: sdkInitRequest,
            callOptions: callOptions
        )
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            sdk.response.whenFailure { error in
                self.log("SDK INIT ERROR \(error)")
                continuation.resume(throwing: error)
            }
            
            sdk.response.whenSuccess { response in
                self.log("SDK INIT SUCCESS \(response)")
                continuation.resume()
            }
        }
    }
    
    public func requestControl() throws {
        requestStream = connection.makeBidirectionalStreamingCall(
            path: "\(prefixURI)BehaviorControl",
            callOptions: callOptions
        ) { response in
            switch response.responseType {
            case .controlGrantedResponse:
                self.log("CONTROL GAINED")
                self.delegate?.didGrantedControl()
            case .keepAlive:
                self.delegate?.keepAlive()
            case .controlLostEvent:
                self.log("CONTROL LOST")
                self.delegate?.didClose()
            default:
                self.log("\(response)")
            }
        }
        
        var controlRequest = Anki_Vector_ExternalInterface_BehaviorControlRequest()
        controlRequest.controlRequest = Anki_Vector_ExternalInterface_ControlRequest()
        controlRequest.controlRequest.priority = .default
        let _ = requestStream?.sendMessage(controlRequest)
    }
    
    public func releaseControl() throws {
        var controlRequest = Anki_Vector_ExternalInterface_BehaviorControlRequest()
        controlRequest.controlRelease = Anki_Vector_ExternalInterface_ControlRelease()
        let _ = requestStream?.sendMessage(controlRequest)
        try requestStream?.eventLoop.close()
        requestStream?.cancel(promise: nil)
        delegate?.didClose()
    }
}

extension VectorConnection: ClientErrorDelegate, ConnectivityStateDelegate {
    public func connectivityStateDidChange(from oldState: ConnectivityState, to newState: ConnectivityState) {
        print("connectivity from \(oldState) to \(newState)")
    }
    
    public func connectionStartedQuiescing() {}
    
    public func didCatchError(_ error: Error, logger: Logging.Logger, file: StaticString, line: Int) {
        log("connection error \(error) at file \(file) at line \(line)")
        delegate?.didClose()
    }
}

private extension VectorConnection {
    func log(_ message: String) {
        logger.debug("\(message)")
    }
}

extension VectorConnection: Behavior {
    public func setHeadAngle(_ angle: Float) async throws {
        var request: Anki_Vector_ExternalInterface_SetHeadAngleRequest = .init()
        request.angleRad = angle * Float.pi / 180.0
        request.accelRadPerSec2 = 10
        request.maxSpeedRadPerSec = 10
        request.idTag = VectorConnection.firstSDKTag
        let call: UnaryCall<Anki_Vector_ExternalInterface_SetHeadAngleRequest,
            Anki_Vector_ExternalInterface_SetHeadAngleResponse> = connection.makeUnaryCall(
            path: "\(prefixURI)SetHeadAngle",
            request: request,
            callOptions: callOptions
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            call.response.whenSuccess { _ in
                continuation.resume(returning: ())
            }
            call.response.whenFailure { error in
                continuation.resume(throwing: error)
            }
        }
    }
    
    public func say(text: String) async throws {
        var request: Anki_Vector_ExternalInterface_SayTextRequest = .init()
        request.text = text
        request.useVectorVoice = true
        request.durationScalar = 1.0
        let call: UnaryCall<Anki_Vector_ExternalInterface_SayTextRequest,
            Anki_Vector_ExternalInterface_SayTextResponse> = connection.makeUnaryCall(
            path: "\(prefixURI)SayText",
            request: request,
            callOptions: callOptions
        )
        return try await withCheckedThrowingContinuation { continuation in
            call.response.whenSuccess { _ in
                continuation.resume(returning: ())
            }
            call.response.whenFailure { error in
                continuation.resume(throwing: error)
            }
        }
    }

    public func setEyeColor(_ hue: Float, _ sat: Float) async throws {
        var eyeColorRequest = Anki_Vector_ExternalInterface_SetEyeColorRequest()
        eyeColorRequest.hue = hue
        eyeColorRequest.saturation = sat
        let call: UnaryCall<Anki_Vector_ExternalInterface_SetEyeColorRequest,
            Anki_Vector_ExternalInterface_SetEyeColorResponse> = connection.makeUnaryCall(
            path: "\(prefixURI)SetEyeColor",
            request: eyeColorRequest, callOptions: callOptions
        )

        return try await withCheckedThrowingContinuation { continuation in
            call.response.whenSuccess { _ in
                continuation.resume(returning: ())
            }
            call.response.whenFailure { error in
                continuation.resume(throwing: error)
            }
        }
    }

    public func move(_ distance: Float, speed: Float, animate: Bool) async throws {
        var request: Anki_Vector_ExternalInterface_DriveStraightRequest = .init()
        request.distMm = distance
        request.speedMmps = speed
        request.shouldPlayAnimation = animate
        let call: UnaryCall<Anki_Vector_ExternalInterface_DriveStraightRequest,
            Anki_Vector_ExternalInterface_DriveStraightResponse> = connection.makeUnaryCall(
            path: "\(prefixURI)DriveStraight",
            request: request,
            callOptions: callOptions
        )
        return try await withCheckedThrowingContinuation { continuation in
            call.response.whenSuccess { _ in
                continuation.resume(returning: ())
            }
            call.response.whenFailure { error in
                continuation.resume(throwing: error)
            }
        }
    }

    public func turn(_ angle: Float, speed: Float, accel: Float, angleTolerance: Float) async throws {
        var request: Anki_Vector_ExternalInterface_TurnInPlaceRequest = .init()
        request.angleRad = angle * Float.pi / 180.0
        request.speedRadPerSec = speed
        request.accelRadPerSec2 = accel
        request.tolRad = angleTolerance
        request.idTag = VectorConnection.firstSDKTag
        let call: UnaryCall<Anki_Vector_ExternalInterface_TurnInPlaceRequest,
            Anki_Vector_ExternalInterface_TurnInPlaceResponse> = connection.makeUnaryCall(
            path: "\(prefixURI)TurnInPlace",
            request: request,
            callOptions: callOptions
        )
        return try await withCheckedThrowingContinuation { continuation in
            call.response.whenSuccess { _ in
                continuation.resume(returning: ())
            }
            call.response.whenFailure { error in
                continuation.resume(throwing: error)
            }
        }
    }
    
    public func driveOnCharger() async throws {
        let request: Anki_Vector_ExternalInterface_DriveOnChargerRequest = .init()
        let call: UnaryCall<Anki_Vector_ExternalInterface_DriveOnChargerRequest,
            Anki_Vector_ExternalInterface_DriveOnChargerResponse> = connection.makeUnaryCall(
            path: "\(prefixURI)DriveOnCharger",
            request: request,
            callOptions: callOptions
        )
        return try await withCheckedThrowingContinuation { continuation in
            call.response.whenSuccess { _ in
                continuation.resume(returning: ())
            }
            call.response.whenFailure { error in
                continuation.resume(throwing: error)
            }
        }
    }

    public func driveOffCharger() async throws {
        let request: Anki_Vector_ExternalInterface_DriveOffChargerRequest = .init()
        let call: UnaryCall<Anki_Vector_ExternalInterface_DriveOffChargerRequest,
            Anki_Vector_ExternalInterface_DriveOffChargerResponse>
            = connection.makeUnaryCall(
                path: "\(prefixURI)DriveOffCharger",
                request: request,
                callOptions: callOptions
            )

        return try await withCheckedThrowingContinuation { continuation in
            call.response.whenSuccess { _ in
                continuation.resume(returning: ())
            }
            call.response.whenFailure { error in
                continuation.resume(throwing: error)
            }
        }
    }
    
    public var battery: VectorBatteryState? {
        get async throws {
            let request: Anki_Vector_ExternalInterface_BatteryStateRequest = .init()
            let call: UnaryCall<Anki_Vector_ExternalInterface_BatteryStateRequest,
                Anki_Vector_ExternalInterface_BatteryStateResponse>
                = connection.makeUnaryCall(
                    path: "\(prefixURI)BatteryState",
                    request: request,
                    callOptions: callOptions
                )

            return try await withCheckedThrowingContinuation { continuation in
                call.response.whenSuccess { result in
                    if result.isCharging {
                        continuation.resume(returning: .charging)
                    } else {
                        continuation.resume(returning: .init(with: result.batteryLevel))
                    }
                }
                call.response.whenFailure { error in
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

extension VectorConnection: Camera {
    public func requestCameraFeed() throws -> AsyncStream<VectorCameraFrame> {
        .init { continuation in
            typealias CameraStream = ServerStreamingCall<Anki_Vector_ExternalInterface_CameraFeedRequest,
                Anki_Vector_ExternalInterface_CameraFeedResponse>
            let _: CameraStream = connection.makeServerStreamingCall(
                path: "\(prefixURI)CameraFeed",
                request: .init(),
                callOptions: callOptions,
                handler: { message in
                    continuation.yield(.init(data: message.data, encoding: message.imageEncoding))
                }
            )
        }
    }
}

extension VectorConnection: Audio {
    public func requestMicFeed() throws -> AsyncStream<AudioFrame> {
        .init { continuation in
            typealias CameraStream = ServerStreamingCall<Anki_Vector_ExternalInterface_AudioFeedRequest,
                Anki_Vector_ExternalInterface_AudioFeedResponse>
            let _: CameraStream = connection.makeServerStreamingCall(
                path: "\(prefixURI)AudioFeed",
                request: .init(),
                callOptions: callOptions,
                handler: { message in
                    continuation.yield(.init(
                        data: message.signalPower,
                        timestamp: message.robotTimeStamp,
                        direction: message.sourceDirection
                    ))
                }
            )
        }
    }
    
    public func playAudio(stream: AsyncStream<AudioFrame>) throws {
        let audioCall: BidirectionalStreamingCall<Anki_Vector_ExternalInterface_ExternalAudioStreamRequest,
            Anki_Vector_ExternalInterface_ExternalAudioStreamResponse> = connection.makeBidirectionalStreamingCall(
            path: "\(prefixURI)ExternalAudioStreamPlayback",
            callOptions: callOptions,
            handler: { message in
                switch message.audioResponseType {
                case .audioStreamPlaybackComplete(let complete):
                    print(complete)
                case .audioStreamPlaybackFailyer(let failure):
                    print(failure)
                case .audioStreamBufferOverrun(let overrun):
                    print(overrun)
                case .none:
                    print("none")
                }
            }
        )
        
        Task {
            var prepareRequest: Anki_Vector_ExternalInterface_ExternalAudioStreamRequest = .init()
            prepareRequest.audioStreamPrepare = .init()
            prepareRequest.audioStreamPrepare.audioVolume = 50
            prepareRequest.audioStreamPrepare.audioFrameRate = 11025
            let _ = audioCall.sendMessage(prepareRequest)
            
            for await chunk in stream {
                var chunkRequest: Anki_Vector_ExternalInterface_ExternalAudioStreamRequest = .init()
                chunkRequest.audioStreamChunk = .init()
                chunkRequest.audioStreamChunk.audioChunkSamples = chunk.data
                chunkRequest.audioStreamChunk.audioChunkSizeBytes = 1024
                let _ = audioCall.sendMessage(chunkRequest)
            }
            
            var completeRequest: Anki_Vector_ExternalInterface_ExternalAudioStreamRequest = .init()
            completeRequest.audioStreamComplete = .init()
            let _ = audioCall.sendMessage(completeRequest)
        }
    }
}
