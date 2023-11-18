// swiftlint:disable:next file_header
import Combine
import Connection
import Foundation
import os.log

public final class ConnectionModel: @unchecked Sendable {
    typealias VectorDevice = Vector & Behavior & Camera & Audio & Sendable
    typealias PathfinderDevice = Pathfinder & Camera & Audio & PathfinderControl & Sendable

    public enum ConnectionModelState {
        case disconnected
        case connecting
        case online
    }

    /// Vector behavior API access
    /// - Description nil means vector is not connected
    /// - Returns Behavior optional type entity
    public var vector: Behavior? {
        vectorDevice
    }

    /// Pathfinder peripheral API access
    /// - Description nil means pathfinder is not connected
    /// - Returns Control optional type entity
    public var pathfinder: PathfinderControl? {
        pathfinderDevice
    }

    /// Vector camera feed access
    /// - Description grants camera feed
    /// - Returns optinal AsyncStream with camera feed
    public var camera: Camera? {
        vectorDevice ?? pathfinderDevice
    }

    /// Vector microphone feed access
    /// - Description grants microphone feed
    /// - Returns optinal AsyncStream with microphone feed
    public var mic: AsyncStream<VectorAudioFrame>? {
        get throws {
            try vectorDevice?.requestMicFeed()
        }
    }

    /// Vector speaker access
    /// - Description returns speaker access for vector device only
    /// - Returns optinal  audio protocol impl object
    public var audio: Audio? {
        vectorDevice ?? pathfinderDevice
    }

    /// Vector battery state
    /// - Description returns current battery state
    public var battery: VectorBatteryState? {
        get async throws {
            if let vectorDevice {
                return try await vectorDevice.battery
            } else if let pathfinderDevice {
                return await withCheckedContinuation { continuation in
                    var cancellable: AnyCancellable?
                    cancellable = pathfinderDevice
                        .battery
                        .sink { value in
                            switch value {
                            case 2430...3000:
                                continuation.resume(returning: .charging)
                            case 1000...2430:
                                continuation.resume(returning: VectorBatteryState.percent(100 * value / 2430))
                            default:
                                continuation.resume(returning: .unknown)
                            }
                            cancellable?.cancel()
                        }
                }
            } else {
                return nil
            }
        }
    }

    /// Socket connection
    /// - Description return socket connection if there is any
    /// - Returns optinal socket connection instance
    public var socket: SocketConnection {
        socketConnection
    }

    /// Vector's connection state reactive property
    public let connectionState: CurrentValueSubject<ConnectionModelState, Never> = .init(.disconnected)

    /// Vector's robot state reactive property
    public let vectorState: PassthroughSubject<Anki_Vector_ExternalInterface_RobotState, Never> = .init()

    /// Socket connection state reactive property
    public let socketState: CurrentValueSubject<ConnectionModelState, Never> = .init(.disconnected)

    private var vectorDevice: VectorDevice?
    private var pathfinderDevice: PathfinderDevice?
    private var socketConnection = SocketConnection()
    private var bag = Set<AnyCancellable>()
    private let logger = Logger(subsystem: "com.mirfirstsnow.ivector", category: "main")
    private lazy var tts = TextToSpeech()

    public init() {
        bind()
    }

    public func bind() {
        connectionState
            .removeDuplicates(by: { $0 == $1 })
            .sink(receiveValue: { state in self.process(state: state) })
            .store(in: &bag)
    }

    public func connect(with ipAddress: String, port: Int = 443) async throws {
        guard case .disconnected = connectionState.value else {
            return
        }

        vectorDevice = try VectorConnection(with: ipAddress, port: port)
        vectorDevice?.delegate = self

        do {
            connectionState.send(.connecting)
            try vectorDevice?.requestControl()
        } catch {
            logger.error("\(error.localizedDescription)")
            connectionState.send(.disconnected)
        }
    }

    public func connect(with bleID: String = "PF2") async throws {
        guard case .disconnected = connectionState.value else {
            return
        }

        pathfinderDevice = PathfinderConnection(with: bleID)
        connectionState.value = .connecting
        try await pathfinderDevice?.connect()
        connectionState.value = .online
        pathfinderDevice?.online
            .map { $0 ? ConnectionModelState.online : ConnectionModelState.disconnected }
            .sink(receiveValue: { self.connectionState.value = $0 })
            .store(in: &bag)
    }

    public func mock() async {
        guard case .disconnected = connectionState.value else {
            return
        }

        vectorDevice = MockedConnection()
        vectorDevice?.delegate = self
        do {
            connectionState.send(.connecting)
            try vectorDevice?.requestControl()
        } catch {
            logger.error("\(error.localizedDescription)")
            connectionState.send(.disconnected)
        }
    }

    public func socket(with ipAddress: String, port: Int) async throws {
        socketConnection.online
            .receive(on: RunLoop.main)
            .replaceError(with: false)
            .sink { [weak self] online in self?.socketState.send(online ? .online : .disconnected) }
            .store(in: &bag)
        try socketConnection.connect(with: ipAddress, websocketPort: port)
    }

    public func disconnect() {
        do {
            try vectorDevice?.release()
            pathfinderDevice?.disconnect()
            socket.disconnect()
            vectorDevice = nil
        } catch {
            self.logger.error("\(error.localizedDescription)")
            connectionState.send(.disconnected)
        }
    }

    /// Says text with vector speaker hardware
    public func say(text: String, locale: Locale = .current) async throws {
        let stream = tts.run(text, locale: locale)
        try await audio?.playAudio(stream: stream)
    }

    /// Plays wav file
    public func play(name: SoundPlayer.SoundName) async throws {
        let player = SoundPlayer()
        let stream = player.play(name: name)
        try await audio?.playAudio(stream: stream)
    }

    private func process(state: ConnectionModelState) {
        switch state {
        case .online:
            Task.detached { try await self.onConnected() }

        case .connecting:
            logger.debug("connecting...")

        case .disconnected:
            Task.detached { try await self.onDisconnected() }
        }
    }

    private func onConnected() async throws {
        try vectorDevice?.requestEventStream()
    }

    private func onDisconnected() async throws {}
}

extension ConnectionModel: ConnectionDelegate {
    public func didGrantedControl() {
        connectionState.send(.online)
    }

    public func didFailedRequest() {
        connectionState.send(.disconnected)
    }

    public func keepAlive() {
        if connectionState.value == .disconnected {
            connectionState.send(.connecting)
        }
    }

    public func didClose() {
        connectionState.send(.disconnected)
    }

    public func onRobot(state: Anki_Vector_ExternalInterface_RobotState) {
        vectorState.send(state)
    }
}
