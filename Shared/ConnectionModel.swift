import Combine
import Connection
import Features
import Foundation

public final actor ConnectionModel {
    typealias VectorDevice = Connection & Behavior & Camera & Audio

    enum ConnectionModelState {
        case disconnected
        case connecting
        case online
    }

    private var connection: VectorDevice?
    private(set) var state: CurrentValueSubject<ConnectionModelState, Never> = .init(.disconnected)
    private var bag = Set<AnyCancellable>()
    private let od = ObjectDetection()
    
    public var battery: VectorBatteryState? {
        get async throws {
            try? await connection?.battery
        }
    }
    
    func bind() {
        state
            .removeDuplicates(by: { $0 == $1 })
            .sink(receiveValue: { state in self.process(state: state) })
            .store(in: &bag)
        od
            .objects
            .sink { obs in
                let obs1 = obs.sorted(by: { $0.confidence < $1.confidence })
                print(obs.first?.labels.first)
            }
            .store(in: &bag)
    }

    func connect(with ip: String, port: Int = 443) {
        guard case .disconnected = state.value else { return }
        connection = VectorConnection(with: ip, port: port)
        connection?.delegate = self
        do {
            state.send(.connecting)
            try connection?.requestControl()
        } catch {
            print(error)
            state.send(.disconnected)
        }
    }

    func disconnect() {
        do {
            try connection?.releaseControl()
            connection = nil
        } catch {
            print(error)
            state.send(.disconnected)
        }
    }

    func process(state: ConnectionModelState) {
        switch state {
        case .online:
            Task {
                try await connection?.setEyeColor(1.0, 0.0)
                try await connection?.initSdk()
//                try await connection?.say(text: "HELLO")
//                try await connection?.setHeadAngle(30)
//                print(try await connection?.getBatteryLevel())
            }

            Task {
//                for await frame in try connection.requestMicFeed() {
//                    STT.shared.append(frame.data)
//                }
            }

            Task {
//                for await frame in try connection.requestCameraFeed() {
//                    await MainActor.run {
//                        od.process(frame.data)
//                    }
//                }
            }
        case .connecting:
            print("connecting...")
        case .disconnected:
            break
        }
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
}
