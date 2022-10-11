import Foundation
import Features

public final class ExecutorModel: Executor {
    @Published public var running: Program?
    @Published public var pc: (Int, Int)?

    private let connection: ConnectionModel
    private var task: Task<Bool, Error>?

    public init(with connection: ConnectionModel) {
        self.connection = connection
    }

    public func run(program: Program) {
        running = program
        task = Task.detached(operation: {
            do {
                var pc = 1
                let instructions = try await program.instructions
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
        running = nil
        pc = nil
    }
    
    public func input(text: String) {
        print(text)
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
        case .say(let ext) :
            if case .text(let text) = ext {
                try await connection.say(text: text)
            }
        case .play(let ext):
            if case .sound(let sound) = ext, let sound {
                try await connection.play(name: sound)
            }
        case .forward(let ext):
            if case .distance(let mm) = ext {
                try await connection.behavior?.move(Float(mm), speed: 10, animate: true)
            }
        case .right(let ext):
            if case .distance(let mm) = ext {
                try await connection.behavior?.turn(90, speed: 10, accel: 1, angleTolerance: 1)
                try await connection.behavior?.move(Float(mm), speed: 10, animate: true)
            }
        case .left(let ext):
            if case .distance(let mm) = ext {
                try await connection.behavior?.turn(-90, speed: 10, accel: 1, angleTolerance: 1)
                try await connection.behavior?.move(Float(mm), speed: 10, animate: true)
            }
        case .backward(let ext):
            if case .distance(let mm) = ext {
                try await connection.behavior?.turn(180, speed: 10, accel: 1, angleTolerance: 1)
                try await connection.behavior?.move(Float(mm), speed: 10, animate: true)
            }
        case .rotate(let ext):
            if case .angle(let angle) = ext {
                try await connection.behavior?.turn(Float(angle), speed: 10, accel: 1, angleTolerance: 1)
            }
        case .pause(let ext):
            if case .sec(let sec) = ext {
                try await Task.sleep(nanoseconds: UInt64(1_000_000_000 * sec))
            }
        case .goto(_, _):
            fatalError("NOT IMPLEMENTED")
        }
    }
}

extension ExecutorModel: ProgrammatorLoad {
    public var programs: [Program] {
        get throws {
            let path = try progLocation()
            let content = try FileManager.default
                .contentsOfDirectory(
                    at: path,
                    includingPropertiesForKeys: nil
                )
            return content.map { Program.init(url: $0) }
        }
    }
}

extension ExecutorModel: Equatable {
    public static func == (lhs: ExecutorModel, rhs: ExecutorModel) -> Bool {
        true
    }
}
