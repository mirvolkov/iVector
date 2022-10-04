import Algorithms
import Collections

public protocol ProgrammatorSync {
    func save(name: String)
}


/// Program composer interface
public protocol Assembler {
    /// Program stored in stack collection
    var program: Deque<Instruction> { get }

    /// Current instruction in edit mode. Not completed.
    var current: Instruction? { get set }

    /// Program size
    var counter: Int { get }

    /// Remove last instruction
    func esc()
}
