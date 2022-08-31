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
        
        let sdk: UnaryCall<Anki_Vector_ExternalInterface_SDKInitializationRequest, Anki_Vector_ExternalInterface_SDKInitializationResponse> = connection.makeUnaryCall(
            path: "/Anki.Vector.external_interface.ExternalInterface/SDKInitialization",
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
            path: "/Anki.Vector.external_interface.ExternalInterface/BehaviorControl",
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
        let call: UnaryCall<Anki_Vector_ExternalInterface_SetHeadAngleRequest, Anki_Vector_ExternalInterface_SetHeadAngleResponse> = connection.makeUnaryCall(
            path: "/Anki.Vector.external_interface.ExternalInterface/SetHeadAngle",
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
        let call: UnaryCall<Anki_Vector_ExternalInterface_SayTextRequest, Anki_Vector_ExternalInterface_SayTextResponse> = connection.makeUnaryCall(
            path: "/Anki.Vector.external_interface.ExternalInterface/SayText",
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
        let call: UnaryCall<Anki_Vector_ExternalInterface_SetEyeColorRequest, Anki_Vector_ExternalInterface_SetEyeColorResponse> = connection.makeUnaryCall(
            path: "/Anki.Vector.external_interface.ExternalInterface/SetEyeColor",
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
        let call: UnaryCall<Anki_Vector_ExternalInterface_DriveStraightRequest, Anki_Vector_ExternalInterface_DriveStraightResponse> = connection.makeUnaryCall(
            path: "/Anki.Vector.external_interface.ExternalInterface/DriveStraight",
            request: request,
            callOptions: callOptions
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            call.response.whenSuccess { _ in
                continuation.resume(returning: ())
            }
            call.response.whenFailure { _ in
                continuation.resume()
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
        let call: UnaryCall<Anki_Vector_ExternalInterface_TurnInPlaceRequest, Anki_Vector_ExternalInterface_TurnInPlaceResponse> = connection.makeUnaryCall(
            path: "/Anki.Vector.external_interface.ExternalInterface/TurnInPlace",
            request: request,
            callOptions: callOptions
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            call.response.whenSuccess { _ in
                continuation.resume(returning: ())
            }
            call.response.whenFailure { _ in
                continuation.resume()
            }
        }
    }
    
    public func driveOnCharger() async throws {
        let request: Anki_Vector_ExternalInterface_DriveOnChargerRequest = .init()
        let call: UnaryCall<Anki_Vector_ExternalInterface_DriveOnChargerRequest, Anki_Vector_ExternalInterface_DriveOnChargerResponse> = connection.makeUnaryCall(
            path: "/Anki.Vector.external_interface.ExternalInterface/DriveOnCharger",
            request: request,
            callOptions: callOptions
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            call.response.whenSuccess { _ in
                continuation.resume(returning: ())
            }
            call.response.whenFailure { _ in
                continuation.resume()
            }
        }
    }
    
    public func driveOffCharger() async throws {
        let request: Anki_Vector_ExternalInterface_DriveOffChargerRequest = .init()
        let call: UnaryCall<Anki_Vector_ExternalInterface_DriveOffChargerRequest, Anki_Vector_ExternalInterface_DriveOffChargerResponse> = connection.makeUnaryCall(
            path: "/Anki.Vector.external_interface.ExternalInterface/DriveOffCharger",
            request: request,
            callOptions: callOptions
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            call.response.whenSuccess { _ in
                continuation.resume(returning: ())
            }
            call.response.whenFailure { _ in
                continuation.resume()
            }
        }
    }
}

extension VectorConnection: Camera {
    public func requestCameraFeed() throws -> AsyncStream<VectorCameraFrame> {
        return .init { continuation in
            typealias CameraStream = ServerStreamingCall<Anki_Vector_ExternalInterface_CameraFeedRequest, Anki_Vector_ExternalInterface_CameraFeedResponse>
            let _: CameraStream = connection.makeServerStreamingCall(
                path: "/Anki.Vector.external_interface.ExternalInterface/CameraFeed",
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
        return .init { continuation in
            typealias CameraStream = ServerStreamingCall<Anki_Vector_ExternalInterface_AudioFeedRequest, Anki_Vector_ExternalInterface_AudioFeedResponse>
            let _: CameraStream = connection.makeServerStreamingCall(
                path: "/Anki.Vector.external_interface.ExternalInterface/AudioFeed",
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
    
    public func playAudio() throws {}
}
