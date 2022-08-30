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
import Security
import os.log

public final class VectorConnection: Connection {
    private let guid: String = "uOXbJIpdSiGgM6SgSoYFUA=="
    private lazy var callOptions: CallOptions = .init(customMetadata: headers)
    private lazy var headers: HPACKHeaders = ["authorization": "Bearer \(guid)"]
    private let logger = Logger(subsystem: "com.mirfirstsnow.ivector", category: "main")
    private let connection: ClientConnection
    private var requestStream: ControlRequestStream?
    
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
    
    public func initSdk() async throws -> Bool {
        var sdkInitRequest = Anki_Vector_ExternalInterface_SDKInitializationRequest()
        sdkInitRequest.sdkModuleVersion = "0.6.0"
        sdkInitRequest.osVersion = "macOS-12.4-arm64-arm-64bit"
        sdkInitRequest.pythonVersion = "3.8.9"
        sdkInitRequest.cpuVersion = "arm64"
        sdkInitRequest.pythonImplementation = "CPython"
        
        let sdkInitCall: UnaryCall<Anki_Vector_ExternalInterface_SDKInitializationRequest, Anki_Vector_ExternalInterface_SDKInitializationResponse> =
            connection.makeUnaryCall(
                path: "/Anki.Vector.external_interface.ExternalInterface/SDKInitialization",
                request: try .init(serializedData: try! sdkInitRequest.serializedData()),
                callOptions: callOptions
            )
        
        return try await withCheckedThrowingContinuation { continuation in
            sdkInitCall.response.whenFailure { error in
                self.log("SDK INIT ERROR \(error)")
                continuation.resume(throwing: error)
            }
            
            sdkInitCall.response.whenSuccess { response in
                self.log("SDK INIT SUCCESS \(response.status.isInitialized)")
                continuation.resume(returning: response.hasStatus)
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
        
    }
    
    public func say(text: String) throws {
        
    }
    
    public func setEyeColor(_ hue: Float, _ sat: Float) async throws {
        var eyeColorRequest = Anki_Vector_ExternalInterface_SetEyeColorRequest()
        eyeColorRequest.hue = hue
        eyeColorRequest.saturation = sat
        
        let eyeColor: UnaryCall<Anki_Vector_ExternalInterface_SetEyeColorRequest, Anki_Vector_ExternalInterface_SetEyeColorResponse> = connection.makeUnaryCall(
            path: "/Anki.Vector.external_interface.ExternalInterface/SetEyeColor",
            request: eyeColorRequest, callOptions: callOptions
        )
        
        return await withCheckedContinuation { continuation in
            eyeColor.response.whenSuccess { _ in
                continuation.resume(returning: ())
            }
            eyeColor.response.whenFailure { _ in
                continuation.resume()
            }
        }
    }
}
