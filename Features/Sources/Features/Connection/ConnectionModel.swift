// swiftlint:disable:next file_header
import Combine
import Connection
import Foundation
import os.log

public final class ConnectionModel: @unchecked Sendable {
    typealias VectorDevice = Vector & Behavior & Camera & Audio & Sendable
    typealias PathfinderDevice = Pathfinder & Camera & PathfinderControl & Sendable

    public enum ConnectionModelState {
        case disconnected
        case connecting
        case online
    }

    /// Vector behavior API access
    /// - Description nil means vector is not connected
    /// - Returns Behavior optional type entity
    public var behavior: Behavior? {
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
        vectorDevice
    }

    /// Vector battery state
    /// - Description returns current battery state
    public var battery: VectorBatteryState? {
        get async throws {
            if let vectorDevice {
                return try await vectorDevice.battery
            } else if let pathfinderDevice {
                return await withCheckedContinuation { continuation in
                    pathfinderDevice
                        .battery
                        .sink { value in
                            continuation.resume(returning: VectorBatteryState.percent(value))
                        }
                        .store(in: &bag)
                }
            } else {
                return nil
            }
        }
    }

    /// Socket connection
    /// - Description return socket connection if there is any
    /// - Returns optinal socket connection instance
    public var socket: SocketConnection? {
        socketConnection
    }

    /// Vector's connection state reactive property
    public let state: CurrentValueSubject<ConnectionModelState, Never> = .init(.disconnected)

    /// Vector's robot state reactive property
    public let robotState: PassthroughSubject<Anki_Vector_ExternalInterface_RobotState, Never> = .init()

    /// Socket connection state reactive property
    public let socketOnline: CurrentValueSubject<Bool, SocketConnection.SocketError> = .init(false)

    private var vectorDevice: VectorDevice?
    private var pathfinderDevice: PathfinderDevice?
    private var socketConnection: SocketConnection?
    private var bag = Set<AnyCancellable>()
    private let logger = Logger(subsystem: "com.mirfirstsnow.ivector", category: "main")
    private lazy var tts = TextToSpeech()
    private lazy var stt = SpeechToText()

    public init() {
        bind()
    }

    public func bind() {
        state
            .removeDuplicates(by: { $0 == $1 })
            .sink(receiveValue: { state in self.process(state: state) })
            .store(in: &bag)
    }

    public func connect(with ipAddress: String, port: Int = 443) async throws {
        guard case .disconnected = state.value else {
            return
        }

        vectorDevice = try VectorConnection(with: ipAddress, port: port)
        vectorDevice?.delegate = self

        do {
            state.send(.connecting)
            try vectorDevice?.requestControl()
        } catch {
            logger.error("\(error.localizedDescription)")
            state.send(.disconnected)
        }
    }

    public func connect(with bleID: String = "PF2") async throws {
        guard case .disconnected = state.value else {
            return
        }

        pathfinderDevice = PathfinderConnection(with: bleID)
        state.value = .connecting
        try await pathfinderDevice?.connect()
        state.value = .online
        pathfinderDevice?.online
            .map { $0 ? ConnectionModelState.online : ConnectionModelState.disconnected }
            .sink(receiveValue: { self.state.value = $0 })
            .store(in: &bag)
    }

    public func mock() async {
        guard case .disconnected = state.value else {
            return
        }

        vectorDevice = MockedConnection()
        vectorDevice?.delegate = self
        do {
            state.send(.connecting)
            try vectorDevice?.requestControl()
        } catch {
            logger.error("\(error.localizedDescription)")
            state.send(.disconnected)
        }
    }

    public func socket(with ipAddress: String, port: Int) async throws {
        socketConnection = try .init(with: ipAddress, websocketPort: port)
        socketConnection?.online
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { [weak self] completion in self?.socketOnline.send(completion: completion) },
                receiveValue: { [weak self] online in self?.socketOnline.send(online) }
            )
            .store(in: &bag)
        socketConnection?.connect()
    }

    public func disconnect() {
        do {
            try vectorDevice?.release()
            pathfinderDevice?.disconnect()
            socket?.disconnect()
            vectorDevice = nil
        } catch {
            self.logger.error("\(error.localizedDescription)")
            state.send(.disconnected)
        }
    }

    /// Says text with vector speaker hardware
    public func say(text: String, locale: Locale = .current) async throws {
        let stream = tts.run(text, locale: locale)
        try await vectorDevice?.playAudio(stream: stream)
    }

    /// Plays wav file
    public func play(name: SoundPlayer.SoundName) async throws {
        let player = SoundPlayer()
        let stream = player.play(name: name)
        try await vectorDevice?.playAudio(stream: stream)
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
        state.send(.online)
    }

    public func didFailedRequest() {
        state.send(.disconnected)
    }

    public func keepAlive() {
        if state.value == .disconnected {
            state.send(.connecting)
        }
    }

    public func didClose() {
        state.send(.disconnected)
    }

    public func onRobot(state: Anki_Vector_ExternalInterface_RobotState) {
        robotState.send(state)
    }
}
