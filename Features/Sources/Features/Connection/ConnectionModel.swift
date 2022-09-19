import Combine
import Connection
import Foundation
import os.log

public final actor ConnectionModel {
    typealias VectorDevice = Connection & Behavior & Camera & Audio

    public enum ConnectionModelState {
        case disconnected
        case connecting
        case online
    }

    /// Vector's battery condition property
    /// - Description battery conditions are FULL/NORMAL/LOW/CHARGING
    /// - Returns battery state asyhc value
    public var battery: VectorBatteryState {
        get async throws {
            guard let battery = try? await connection?.battery else {
                throw ConnectionError.notConnected
            }

            return battery
        }
    }

    /// Vector behavior API access
    /// - Description nil means vector is not connected
    /// - Returns Behavior optional type entity
    public var behavior: Behavior? {
        connection
    }

    /// Vector camera feed access
    /// - Description grants camera feed
    /// - Returns optinal AsyncStream with camera feed
    public var camera: AsyncStream<VectorCameraFrame>? {
        get throws {
            try connection?.requestCameraFeed()
        }
    }

    /// Vector microphone feed access
    /// - Description grants microphone feed
    /// - Returns optinal AsyncStream with microphone feed
    public var mic: AsyncStream<VectorAudioFrame>? {
        get throws {
            try connection?.requestMicFeed()
        }
    }

    /// Vector's connection state reactive property
    public var state: CurrentValueSubject<ConnectionModelState, Never> = .init(.disconnected)

    /// Vector's robot state reactive property
    public var robotState: PassthroughSubject<Anki_Vector_ExternalInterface_RobotState, Never> = .init()

    private var connection: VectorDevice?
    private var bag = Set<AnyCancellable>()
    private let logger = Logger(subsystem: "com.mirfirstsnow.ivector", category: "main")
    private lazy var tts = TextToSpeech()

    public init() {}

    public func bind() {
        state
            .removeDuplicates(by: { $0 == $1 })
            .sink(receiveValue: { state in self.process(state: state) })
            .store(in: &bag)
    }

    public func connect(with ipAddress: String, port: Int = 443) {
        guard case .disconnected = state.value else {
            return
        }

        connection = VectorConnection(with: ipAddress, port: port)
        connection?.delegate = self
        do {
            state.send(.connecting)
            try connection?.requestControl()
        } catch {
            self.logger.error("\(error.localizedDescription)")
            state.send(.disconnected)
        }
    }

    public func disconnect() {
        do {
            try connection?.release()
            connection = nil
        } catch {
            self.logger.error("\(error.localizedDescription)")
            state.send(.disconnected)
        }
    }

    /// Says text with vector speaker hardware
    public func say(text: String, locale: Locale = .current) throws {
        let stream = tts.run(text, locale: locale)
        try connection?.playAudio(stream: stream)
    }

    /// Plays wav file 
    public func play(name: SoundPlayer.SoundName) throws {
        let player = SoundPlayer()
        let stream = player.play(name: name)
        try connection?.playAudio(stream: stream)
    }

    private func process(state: ConnectionModelState) {
        switch state {
        case .online:
            Task.detached { try await self.onConnected() }

        case .connecting:
            logger.debug("connecting...")

        case .disconnected:
            break
        }
    }

    private func onConnected() throws {
        try connection?.requestEventStream()
    }
}

extension ConnectionModel: ConnectionDelegate {
    public nonisolated func didGrantedControl() {
        Task.detached { await self.state.send(.online) }
    }

    public nonisolated func didFailedRequest() {
        Task.detached { await self.state.send(.disconnected) }
    }

    public nonisolated func keepAlive() {
        Task.detached {
            if await self.state.value != .online {
                await self.state.send(.connecting)
            }
        }
    }

    public nonisolated func didClose() {
        Task.detached {
            await self.state.send(.disconnected)
        }
    }

    public nonisolated func onRobot(state: Anki_Vector_ExternalInterface_RobotState) {
        Task.detached { await self.robotState.send(state) }
    }
}

public extension ConnectionModel {
    func dock() async throws {
        try await connection?.driveOnCharger()
    }

    func undock() async throws {
        try await connection?.driveOffCharger()
    }
}
