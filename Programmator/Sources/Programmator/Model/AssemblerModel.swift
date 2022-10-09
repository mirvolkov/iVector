import Collections
import Combine
import Foundation

public final class AssemblerModel: Assembler, ObservableObject {
    @Published public var program: DequeModule.Deque<Instruction> = []
    @Published public var current: Instruction?

    public var ext: ExtensionBox? {
        get { current?.ext }
        set { current?.ext = newValue }
    }

    public init() { }

    public func extend(with digit: Int) {
        switch ext {
        case .distance(let value):
            guard value < 100 else { return }
            ext = .distance(value*10 + digit)
        case .angle(let value):
            guard value < 100 else { return }
            ext = .angle(value*10 + digit)
        case .sec(let value):
            guard value < 30 else { return }
            ext = .sec(value*10 + digit)
        default:
            break
        }
    }

    public func extend(with string: String) {
        switch ext {
        case .text(_):
            ext = .text(string)
        default:
            break
        }
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
        let rootPath = try progLocation()
        let json = try JSONEncoder().encode(program)
        let docPath = makeFilePath(root: rootPath, filename: name)
        try json.write(to: docPath)
    }

    func makeFilePath(root: URL, filename: String) -> URL {
        return root
            .appendingPathComponent(filename)
            .appendingPathExtension(progFileExtension)
    }
}
