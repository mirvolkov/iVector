import Collections
import Connection
import Features
import Foundation
import SwiftBus

public final class ExecutorModel: Executor {
    enum ExecutorError: Error {
        case notSupported
    }

    struct ExecutorCondition {
        let value: Extension.ConditionValue
        let program: Extension.ProgramID

        init?(_ value: Extension.ConditionValue?, _ program: Extension.ProgramID) {
            guard let value else { return nil }
            self.value = value
            self.program = program
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

    /// Condition (CMP) operation list
    private var conditions: [ExecutorCondition] = []

    public init(with connection: ConnectionModel) {
        self.connection = connection

        connection.socket.listen { (data: AudioFeature.STTData) in
            print(data)
        }
    }

    public func cancel() {
        task?.cancel()
        conditions.removeAll()
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
            self.conditions = instructions
                .map { instruction in
                    switch instruction {
                    case .cmp(let condition, let programID):
                        return ExecutorCondition(condition.value, programID)
                    default:
                        return nil
                    }
                }.compactMap { $0 }

            var stack = instructions.makeIterator()
            while let instruction = stack.next() {
                self.pc = (pc, instructions.count)
                try Task.checkCancellation()
                try await self.run(instruction: instruction)
                pc += 1
            }
        })

        try await task?.value
    }

    private func run(instruction: Instruction) async throws {
        if let behavior = connection.behavior {
            try await run(instruction: instruction, with: behavior)
        }
        if let pathfinder = connection.pathfinder {
            try await run(instruction: instruction, with: pathfinder)
        }
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
                await driver.move(Float(value), speed: 100, direction: true)
            }
        case .right(let ext):
            if let value = ext.value {
                await driver.turn(90, speed: 100)
                await driver.move(Float(value), speed: 100, direction: true)
            }
        case .left(let ext):
            if let value = ext.value {
                await driver.turn(-90, speed: 100)
                await driver.move(Float(value), speed: 100, direction: true)
            }
        case .backward(let ext):
            if let value = ext.value {
                await driver.move(Float(value), speed: 100, direction: false)
            }
        case .rotate(let ext):
            if let value = ext.value {
                await driver.turn(-Float(value), speed: 100)
            }
        case .pause(let ext):
            if let value = ext.value {
                try await Task.sleep(nanoseconds: UInt64(1_000_000_000 * value))
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
                try await Task.sleep(nanoseconds: UInt64(1_000_000_000 * value))
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
            throw ExecutorError.notSupported
        case .laser(let isOn):
            throw ExecutorError.notSupported
        }
    }
}
