import Algorithms
import Collections

/// Program composer interface
public protocol Assembler {
    /// Program stored in stack collection
    var program: Deque<Instruction> { get }

    /// Current instruction in edit mode. Not completed.
    var current: Instruction? { get set }

    /// Current instruction extension
    var ext: ExtensionBox? { get }

    /// Remove last instruction
    func esc()

    /// Enter command
    func enter()
}
