import Collections
import Foundation

public class Program {
    /// Program name
    public var name: String

    /// List of instructions
    public var instructions: Deque<Instruction> {
        get async throws {
            let (data, _) = try await URLSession.shared.data(from: url)
            let instructions = try JSONDecoder().decode([Instruction].self, from: data)
            return .init(instructions)
        }
    }

    private let url: URL

    public init(url: URL) {
        self.name = url.deletingPathExtension().lastPathComponent
        self.url = url
    }
}

extension Program: CustomStringConvertible {
    public var description: String {
        name
    }
}

extension Program: Sendable { }
