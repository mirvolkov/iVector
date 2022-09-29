import Collections

protocol Program {
    /// Program name
    var name: String { get }

    /// List of instructions
    var instructions: Deque<Instruction> { get }
}
