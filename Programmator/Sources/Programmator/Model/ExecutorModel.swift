import Foundation
import Features

public final class ExecutorModel: Executor {
    @Published public var running: Program?
    private let connection: ConnectionModel

    public init(with connection: ConnectionModel) {
        self.connection = connection
    }

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

extension ExecutorModel: Equatable {
    public static func == (lhs: ExecutorModel, rhs: ExecutorModel) -> Bool {
        true
    }
}
