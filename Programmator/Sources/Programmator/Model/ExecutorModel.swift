import Foundation
import Features
import Collections

public final class ExecutorModel: Executor {
    @Published public var running: Program?
    @Published public var pc: (Int, Int)?

    private let connection: ConnectionModel
    private var task: Task<Bool, Error>?
    private var buffer = Deque<String>()
    
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
    
    // TODO: this is mocked solution for stage 1 demo
    public func input(text: String) {
        buffer.append(text)
        
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
                try await connection.behavior?.move(Float(mm), speed: 50, animate: true)
            }
        case .right(let ext):
            if case .distance(let mm) = ext {
                try await connection.behavior?.turn(90, speed: 30, accel: 10, angleTolerance: 0)
                try await connection.behavior?.move(Float(mm), speed: 50, animate: true)
            }
        case .left(let ext):
            if case .distance(let mm) = ext {
                try await connection.behavior?.turn(-90, speed: 30, accel: 10, angleTolerance: 0)
                try await connection.behavior?.move(Float(mm), speed: 50, animate: true)
            }
        case .backward(let ext):
            if case .distance(let mm) = ext {
                try await connection.behavior?.move(-Float(mm), speed: 50, animate: true)
            }
        case .rotate(let ext):
            if case .angle(let angle) = ext {
                try await connection.behavior?.turn(Float(angle), speed: 30, accel: 10, angleTolerance: 0)
            }
        case .pause(let ext):
            if case .sec(let sec) = ext {
                try await Task.sleep(nanoseconds: UInt64(1_000_000_000 * sec))
            }
        case .cmp(_, _):
            fatalError("NOT IMPLEMENTED")
        case .exec(let ext):
            if case .program(let name) = ext,
                let prog = try await AssemblerModel
                .programs
                .first(where: { $0.name == name}) {
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
