import Collections
import Combine

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
