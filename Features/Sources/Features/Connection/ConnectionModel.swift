import Combine
import Connection
import Foundation
import os.log

public final actor ConnectionModel {
    typealias VectorDevice = Connection & Behavior & Camera & Audio & Sendable

    public enum ConnectionModelState {
        case disconnected
        case connecting
        case online
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

    /// Vector's battery state reactive property
    public var battery: PassthroughSubject<VectorBatteryState, Never> = .init()

    private var connection: VectorDevice?
    private var bag = Set<AnyCancellable>()
    private let logger = Logger(subsystem: "com.mirfirstsnow.ivector", category: "main")
    private lazy var tts = TextToSpeech()
    @MainActor private var timer: Timer?

    public init() {
        Task {
            await self.bind()
        }
    }

    public func bind() {
        state
            .removeDuplicates(by: { $0 == $1 })
            .sink(receiveValue: { state in self.process(state: state) })
            .store(in: &bag)
    }

    public nonisolated func connect(with ipAddress: String, port: Int = 443) async throws {
        let connectTask: Task = .detached {
            guard case .disconnected = await self.state.value else {
                return
            }

            await self.setConnection(try VectorConnection(with: ipAddress, port: port))
            await self.connection?.delegate = self
            do {
                await self.state.send(.connecting)
                try await self.connection?.requestControl()
            } catch {
                self.logger.error("\(error.localizedDescription)")
                await self.state.send(.disconnected)
            }
        }

        try await connectTask.result.get()
    }

    public nonisolated func mock() async {
        Task.detached {
            guard case .disconnected = await self.state.value else {
                return
            }

            await self.setConnection(MockedConnection())
            await self.connection?.delegate = self
            do {
                await self.state.send(.connecting)
                try await self.connection?.requestControl()
            } catch {
                self.logger.error("\(error.localizedDescription)")
                await self.state.send(.disconnected)
            }
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
            Task.detached { try await self.onDisconnected() }
        }
    }

    private func onConnected() async throws {
        try connection?.requestEventStream()
        await MainActor.run {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                Task {
                    if let battery = try? await self.connection?.battery {
                        await self.battery.send(battery)
                    }
                }
            })
        }
    }

    private func onDisconnected() async throws {
        await MainActor.run(body: {
            timer?.invalidate()
        })
    }

    private func setConnection(_ connection: VectorDevice?) {
        self.connection = connection
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
            if await self.state.value == .disconnected {
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
