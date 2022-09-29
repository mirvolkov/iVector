protocol Executor {
    /// Running program
    var running: Program? { get }

    /// Run new program
    func run(program: Program)

    /// cancel running program
    func cancel()
}
