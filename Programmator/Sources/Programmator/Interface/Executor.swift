public protocol Executor {
    /// Running program
    var running: Program? { get }

    /// PC Counter/Total commands cound
    var pc: (Int, Int)? { get }

    /// Run new program
    func run(program: Program)

    /// cancel running program
    func cancel()
}
