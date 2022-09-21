enum Instruction {
    case left
    case right
    case towards
    case backwards
}

protocol Program {
    var name: String { get }
    var instructions: [Instruction] { get }
}

protocol ProgrammerModel {
    var current: Program? { get }

    func exec(_ program: Program)
}
