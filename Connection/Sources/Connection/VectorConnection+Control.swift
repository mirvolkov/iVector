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

actor DataAccumulator: Sendable {
    private var data: Data = .init()

    func push(_ chunk: Data) {
        data.append(chunk)
    }

    func pop(_ size: Int) -> Data {
        defer { data.removeFirst(min(data.count, size)) }
        return data.prefix(size)
    }

    func get() -> Data {
        data
    }
}

public enum VectorConnectionError: Error, Equatable {
    case noCertificate
}

public final class VectorConnection: Vector {
    public weak var delegate: ConnectionDelegate?

    let prefixURI = "/Anki.Vector.external_interface.ExternalInterface/"
    let guid: String = "uOXbJIpdSiGgM6SgSoYFUA=="
    lazy var callOptions: CallOptions = .init(customMetadata: headers)
    private lazy var headers: HPACKHeaders = ["authorization": "Bearer \(guid)"]
    private static let logger = Logger(subsystem: "com.mirfirstsnow.ivector", category: "main")
    let connection: ClientConnection
    var requestStream: ControlRequestStream?
    var eventStream: EventStream?

    public init?(with ipAddress: String, port: Int) throws {
        guard let certificatePath = Bundle.module.path(forResource: "Vector-E1B6-003099a9", ofType: "cert") else {
            throw VectorConnectionError.noCertificate
        }

        Self.log("Vector connection init")
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        var tlsConfig = TLSConfiguration.makeClientConfiguration()
        tlsConfig.trustRoots = .file(certificatePath)
        tlsConfig.certificateVerification = .noHostnameVerification
        tlsConfig.applicationProtocols = ["h2"]

        let tls1 = ClientConnection.Configuration.TLS(configuration: tlsConfig)
        var configuration = ClientConnection.Configuration(
            target: .hostAndPort(ipAddress, port),
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
        Self.log("Vector connection deinit")
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
                Self.log("SDK INIT ERROR \(error)")
                continuation.resume(throwing: error)
            }

            sdk.response.whenSuccess { response in
                Self.log("SDK INIT SUCCESS \(response)")
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
                Self.log("CONTROL GAINED")
                self.delegate?.didGrantedControl()

            case .keepAlive:
                self.delegate?.keepAlive()

            case .controlLostEvent:
                Self.log("CONTROL LOST")
                self.delegate?.didClose()

            default:
                Self.log("\(response)")
            }
        }

        var controlRequest = Anki_Vector_ExternalInterface_BehaviorControlRequest()
        controlRequest.controlRequest = Anki_Vector_ExternalInterface_ControlRequest()
        controlRequest.controlRequest.priority = .default
        _ = requestStream?.sendMessage(controlRequest)
    }

    public func release() throws {
        var controlRequest = Anki_Vector_ExternalInterface_BehaviorControlRequest()
        controlRequest.controlRelease = Anki_Vector_ExternalInterface_ControlRelease()
        _ = requestStream?.sendMessage(controlRequest)
        try requestStream?.eventLoop.close()
        try eventStream?.eventLoop.close()
        requestStream?.cancel(promise: nil)
        eventStream?.cancel(promise: nil)
        delegate?.didClose()
    }
}

extension VectorConnection: ClientErrorDelegate, ConnectivityStateDelegate {
    public func connectivityStateDidChange(from oldState: ConnectivityState, to newState: ConnectivityState) {
        Self.log("connectivity from \(oldState) to \(newState)")
    }

    public func connectionStartedQuiescing() {}

    public func didCatchError(_ error: Error, logger: Logging.Logger, file: StaticString, line: Int) {
        Self.log("connection error \(error) at file \(file) at line \(line)")
        delegate?.didClose()
    }
}

/// Logging extension
extension VectorConnection {
    static func log(_ message: String) {
        logger.debug("\(message)")
    }
}
