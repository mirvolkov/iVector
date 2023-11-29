import Collections
import Connection
import Features
import Foundation
import SwiftBus
import SocketIO

public final class ExecutorModel: Executor {
    public enum ExecutorError: Error {
        case notSupported
    }

    public struct ExecutorEvent: SocketConnection.SocketMessage {
        public enum Condition: EventRepresentable, CustomStringConvertible {
            case started
            case finished

            public var description: String {
                switch self {
                case .started:
                    "started"
                case .finished:
                    "finished"
                }
            }
        }

        public let instruction: Instruction
        public let condition: Condition
        public let date: Date = .init()

        public init(instruction: Instruction, condition: Condition) {
            self.instruction = instruction
            self.condition = condition
        }

        public func socketRepresentation() throws -> SocketData {
            [
                "condition": condition.description,
                "instruction": instruction.description,
                "timestamp": date.timeIntervalSince1970
            ]
        }
    }

    @Published public var running: Program?
    @Published public var pc: (Int, Int)?

    /// Connection instance
    public let connection: ConnectionModel

    /// Executor running task. Boolean value shows if task is still running (false = not completed, true = completed)
    private var task: Task<Void, Error>?

    /// Buffer of text input
    private var buffer = Deque<String>()

    public init(with connection: ConnectionModel) {
        self.connection = connection
    }

    public func cancel() {
        task?.cancel()
        running = nil
        pc = nil
    }

    public func input(text: String) {
        buffer.append(text.lowercased())
    }

    public func run(program: Program) async throws {
        running = program
        task = Task.detached(operation: {
            var pc = 1
            let instructions = try await program.instructions
            var stack = instructions.makeIterator()
            while let instruction = stack.next() {
                self.pc = (pc, instructions.count)
                try Task.checkCancellation()
                try await self.run(instruction: instruction)
                pc += 1
            }
            self.running = nil
            self.pc = nil
        })

        try await task?.value // to get error if there is
    }

    private func run(instruction: Instruction) async throws {
        connection.socket.send(ExecutorEvent(instruction: instruction, condition: .started), with: "exec")

        if let behavior = connection.vector {
            try await run(instruction: instruction, with: behavior)
        }

        if let pathfinder = connection.pathfinder {
            try await run(instruction: instruction, with: pathfinder)
        }

        connection.socket.send(ExecutorEvent(instruction: instruction, condition: .finished), with: "exec")
    }
}

extension ExecutorModel: Equatable {
    public static func == (lhs: ExecutorModel, rhs: ExecutorModel) -> Bool {
        true
    }
}

private extension ExecutorModel {
    func run<T: PathfinderControl>(instruction: Instruction, with driver: T) async throws {
        switch instruction {
        case .dock:
            throw ExecutorError.notSupported
        case .lift:
            throw ExecutorError.notSupported
        case .say(let ext):
            if let value = ext.value {
                try await connection.say(text: value)
            }
        case .play(let ext):
            if let value = ext.value {
                try await connection.play(name: value)
            }
        case .forward(let ext):
            if let value = ext.value {
                try await driver.move(Float(value), speed: .max, direction: true)
            }
        case .right(let ext):
            if let value = ext.value {
                try await driver.turn(90, speed: .max)
                try await driver.move(Float(value), speed: .max, direction: true)
            }
        case .left(let ext):
            if let value = ext.value {
                try await driver.turn(-90, speed: .max)
                try await driver.move(Float(value), speed: .max, direction: true)
            }
        case .backward(let ext):
            if let value = ext.value {
                try await driver.move(Float(value), speed: .max, direction: false)
            }
        case .rotate(let ext):
            if let value = ext.value {
                try await driver.turn(-Float(value), speed: .max)
            }
        case .pause(let ext):
            if let value = ext.value {
                try await Task.sleep(for: .milliseconds(UInt64(1_000 * value)))
            }
        case .cmp:
            break
        case .exec(let ext):
            if let value = ext.value,
               let prog = try await AssemblerModel
               .programs
               .first(where: { $0.name == value })
            {
                try await run(program: prog)
            }
        case .light(let isOn):
            await driver.light(isOn)
        case .laser(let isOn):
            await driver.laser(isOn)
        }
    }
}

private extension ExecutorModel {
    func run<T: Behavior>(instruction: Instruction, with driver: T) async throws {
        switch instruction {
        case .dock(let isOn):
            isOn ? try await driver.driveOnCharger() : try await driver.driveOffCharger()
        case .lift(let isOn):
            try await driver.lift(isOn ? 1 : 0)
        case .say(let ext):
            if let value = ext.value {
                try await connection.say(text: value)
            }
        case .play(let ext):
            if let value = ext.value {
                try await connection.play(name: value)
            }
        case .forward(let ext):
            if let value = ext.value {
                try await driver.move(Float(value), speed: 50, animate: true)
            }
        case .right(let ext):
            if let value = ext.value {
                try await driver.turn(90, speed: 30, accel: 10, angleTolerance: 0)
                try await driver.move(Float(value), speed: 50, animate: true)
            }
        case .left(let ext):
            if let value = ext.value {
                try await driver.turn(-90, speed: 30, accel: 10, angleTolerance: 0)
                try await driver.move(Float(value), speed: 50, animate: true)
            }
        case .backward(let ext):
            if let value = ext.value {
                try await driver.move(-Float(value), speed: 50, animate: true)
            }
        case .rotate(let ext):
            if let value = ext.value {
                try await driver.turn(Float(value), speed: 30, accel: 10, angleTolerance: 0)
            }
        case .pause(let ext):
            if let value = ext.value {
                try await Task.sleep(for: .milliseconds(UInt64(1_000 * value)))
            }
        case .cmp:
            break
        case .exec(let ext):
            if let value = ext.value,
               let prog = try await AssemblerModel
               .programs
               .first(where: { $0.name == value })
            {
                try await run(program: prog)
            }
        case .light:
            throw ExecutorError.notSupported
        case .laser:
            throw ExecutorError.notSupported
        }
    }
}
