import Collections
import Combine
import Foundation
import Features

public final class AssemblerModel: Assembler, ObservableObject {
    @Published public var program: DequeModule.Deque<Instruction> = []
    @Published public var current: Instruction?

    public var ext: ExtensionBox? {
        get { current?.ext }
        set { current?.ext = newValue }
    }

    public init() { }

    public func extend<T>(with value: T) {
        switch (value, ext) {
        case (let digit as Int, .distance(let value)):
            guard value < 100 else { return }
            ext = .distance(value*10 + digit)
        case (let digit as Int, .angle(let value)):
            guard value < 100 else { return }
            ext = .angle(value*10 + digit)
        case (let digit as Int, .sec(let value)):
            guard value < 10 else { return }
            ext = .sec(value*10 + digit)
        case (let text as String, .text):
            guard text.count < 16 else { return }
            ext = .text(text)
        case (let sound as SoundPlayer.SoundName, .sound):
            ext = .sound(sound)
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
        program.removeAll()
    }

    public var programs: [Program] {
        get async throws {
            let path = try progLocation()
            let content = try FileManager.default
                .contentsOfDirectory(
                    at: path,
                    includingPropertiesForKeys: nil
                )
            return content.map { Program.init(url: $0) }
        }
    }

    func makeFilePath(root: URL, filename: String) -> URL {
        return root
            .appendingPathComponent(filename)
            .appendingPathExtension(progFileExtension)
    }
}
