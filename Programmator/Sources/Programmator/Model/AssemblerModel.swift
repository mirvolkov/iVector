import Collections
import Combine
import Foundation
import Features

public final class AssemblerModel: Assembler, ObservableObject {
    @Published public var program: DequeModule.Deque<Instruction> = []
    @Published public var current: Instruction?

    public init() { }

    public func extend<T>(with value: T) {
        try? current?.setValue(value)
    }

    public func esc() {
        guard let _ = current else {
            let _ = program.popLast()
            return
        }

        self.current = nil
    }

    public func enter() {
        if let current = current {
            program.append(current)
            self.current = nil
        }
    }
}

extension AssemblerModel: ProgrammatorSave {
    public enum SaveError: Error {
        case alreadyExists
        case fsError
    }

    public func save(name: String) throws {
        let rootPath = try Self.progLocation()
        let json = try JSONEncoder().encode(program)
        let docPath = makeFilePath(root: rootPath, filename: name)
        try json.write(to: docPath)
        program.removeAll()
    }

    func makeFilePath(root: URL, filename: String) -> URL {
        return root
            .appendingPathComponent(filename)
            .appendingPathExtension(Self.progFileExtension)
    }
}
