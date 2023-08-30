import Combine
import Connection
import Foundation
import os.log

public final class ConnectionModel {
    typealias VectorDevice = Vector & Behavior & Camera & Audio & Sendable
    typealias PathfinderDevice = Pathfinder & Sendable

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

    /// Vector camera feed access
    /// - Description grants camera feed
    /// - Returns optinal AsyncStream with camera feed
    public var camera: Camera? {
        vectorDevice
    }

    /// Vector microphone feed access
    /// - Description grants microphone feed
    /// - Returns optinal AsyncStream with microphone feed
    public var mic: AsyncStream<VectorAudioFrame>? {
        get throws {
            try vectorDevice?.requestMicFeed()
        }
    }

    /// Vector battery state
    /// - Description returns current battery state
    public var battery: VectorBatteryState? {
        get async throws {
            try await vectorDevice?.battery
        }
    }

    /// Vector's connection state reactive property
    public var state: CurrentValueSubject<ConnectionModelState, Never> = .init(.disconnected)

    /// Vector's robot state reactive property
    public var robotState: PassthroughSubject<Anki_Vector_ExternalInterface_RobotState, Never> = .init()

    private var vectorDevice: VectorDevice?
    private var pathfinderDevice: PathfinderDevice?

    private var bag = Set<AnyCancellable>()
    private let logger = Logger(subsystem: "com.mirfirstsnow.ivector", category: "main")
    private lazy var tts = TextToSpeech()

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

        setConnection(try VectorConnection(with: ipAddress, port: port))
        vectorDevice?.delegate = self

        do {
            state.send(.connecting)
            try vectorDevice?.requestControl()
        } catch {
            logger.error("\(error.localizedDescription)")
            state.send(.disconnected)
        }
    }

    public func connect() async throws {
        pathfinderDevice = PathfinderConnection()
    }

    public func mock() async {
        guard case .disconnected = state.value else {
            return
        }

        setConnection(MockedConnection())
        vectorDevice?.delegate = self
        do {
            state.send(.connecting)
            try vectorDevice?.requestControl()
        } catch {
            logger.error("\(error.localizedDescription)")
            state.send(.disconnected)
        }
    }

    public func disconnect() {
        do {
            try vectorDevice?.release()
            vectorDevice = nil
        } catch {
            self.logger.error("\(error.localizedDescription)")
            state.send(.disconnected)
        }
    }

    /// Says text with vector speaker hardware
    public func say(text: String, locale: Locale = .current) throws {
        let stream = tts.run(text, locale: locale)
        try vectorDevice?.playAudio(stream: stream)
    }

    /// Plays wav file
    public func play(name: SoundPlayer.SoundName) throws {
        let player = SoundPlayer()
        let stream = player.play(name: name)
        try vectorDevice?.playAudio(stream: stream)
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

    private func onDisconnected() async throws {
    }

    private func setConnection(_ connection: VectorDevice?) {
        self.vectorDevice = connection
    }
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
