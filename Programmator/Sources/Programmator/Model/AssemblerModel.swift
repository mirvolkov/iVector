import Collections
import Combine

public final class AssemblerModel: Assembler, ObservableObject {
    @Published public var program: DequeModule.Deque<Instruction> = []
    @Published public var current: Instruction?
    @Published public var counter: Int = 0

    public init() {}

    public func esc() {}
}
