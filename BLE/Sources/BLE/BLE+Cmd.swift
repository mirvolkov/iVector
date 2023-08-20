import Combine
import Foundation

public actor Commander {
    public enum CmdError: Error {
        case timeout
        case encodeError
    }

    enum State {
        case full
        case empty(waiters: [CheckedContinuation<Void, Never>])
    }

    private let txID: String
    private let rxID: String
    private nonisolated let io: BLEIO
    private nonisolated let rxHandler: PassthroughSubject<String, Never>
    private nonisolated let queue = DispatchQueue(label: "BLE_CMD")
    private var bag = Set<AnyCancellable>()
    private var state: State = .full

    public init(with io: BLEIO, txID: String, rxID: String) {
        self.io = io
        self.txID = txID
        self.rxID = rxID
        self.rxHandler = PassthroughSubject<String, Never>()
        self.io.listen(for: rxID) { ccmd in
            Task.detached {
                self.rxHandler.send(ccmd.replacingOccurrences(of: "\n", with: ""))
            }
        }
    }

    public func run(cmd: String) async throws -> String? {
        await self.enter()
        defer {
            self.exit()
        }
        guard let data = cmd.data(using: .ascii) else {
            throw Commander.CmdError.encodeError
        }
        print(cmd)
        self.io.write(data: data, charID: txID)
        return try await self.block(cmd: cmd)
    }

    private func enter() async {
        switch self.state {
        case .full:
            self.state = .empty(waiters: [])
            return
        case .empty(waiters: var waiters):
            await withCheckedContinuation {
                waiters.append($0)
                self.state = .empty(waiters: waiters)
            }
        }
    }

    private func exit() {
        guard case .empty(waiters: var waiters) = self.state else {
            fatalError("Exiting in invalid state")
        }

        if waiters.isEmpty {
            self.state = .full
            return
        }

        let nextWaiter = waiters.removeFirst()
        self.state = .empty(waiters: waiters)
        nextWaiter.resume()
    }

    private func block(cmd: String) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            rxHandler
                .filter { $0 == cmd }
                .receive(on: queue)
                .setFailureType(to: Self.CmdError.self)
                .timeout(1, scheduler: queue, customError: { CmdError.timeout })
                .first()
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    default:
                        break
                    }
                }, receiveValue: { value in
                    continuation.resume(returning: value)
                })
                .store(in: &bag)
        }
    }
}
