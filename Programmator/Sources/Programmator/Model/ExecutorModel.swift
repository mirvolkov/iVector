import Foundation

public final class ExecutorModel: Executor {
    @Published public var running: Program?

    public init() { }

    public func run(program: Program) {
        running = program
    }

    public func cancel() {
        running = nil
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
