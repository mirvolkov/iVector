import Collections
import Features
import Foundation

public final class ExecutorModel: Executor {
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
    private let connection: ConnectionModel

    /// Executor running task. Boolean value shows if task is still running (false = not completed, true = completed)
    private var task: Task<Bool, Error>?

    /// Buffer of text input
    private var buffer = Deque<String>()

    /// Condition (CMP) operation list
    private var conditions: [ExecutorCondition] = []

    public init(with connection: ConnectionModel) {
        self.connection = connection
    }

    public func run(program: Program) {
        running = program
        task = Task.detached(operation: {
            do {
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

                return true
            } catch {
                print(error)
                return false
            }
        })
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

    private func run(instruction: Instruction) async throws {
        switch instruction {
        case .dock:
            try await connection.dock()
        case .undock:
            try await connection.undock()
        case .liftUp:
            try await connection.behavior?.lift(1)
        case .liftDown:
            try await connection.behavior?.lift(0)
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
                try await connection.behavior?.move(Float(value), speed: 50, animate: true)
            }
        case .right(let ext):
            if let value = ext.value {
                try await connection.behavior?.turn(90, speed: 30, accel: 10, angleTolerance: 0)
                try await connection.behavior?.move(Float(value), speed: 50, animate: true)
            }
        case .left(let ext):
            if let value = ext.value {
                try await connection.behavior?.turn(-90, speed: 30, accel: 10, angleTolerance: 0)
                try await connection.behavior?.move(Float(value), speed: 50, animate: true)
            }
        case .backward(let ext):
            if let value = ext.value {
                try await connection.behavior?.move(-Float(value), speed: 50, animate: true)
            }
        case .rotate(let ext):
            if let value = ext.value {
                try await connection.behavior?.turn(Float(value), speed: 30, accel: 10, angleTolerance: 0)
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
                run(program: prog)
            }
        }
    }
}

extension ExecutorModel: Equatable {
    public static func == (lhs: ExecutorModel, rhs: ExecutorModel) -> Bool {
        true
    }
}
