public protocol Executor {    
    /// Running program
    var running: Program? { get }
    
    /// PC Counter/Total commands cound
    var pc: (Int, Int)? { get }
    
    /// Run new program
    /// - Throws  possible error
    func run(program: Program) async throws
    
    /// cancel running program
    func cancel()
    
    /// process text input (most preferable speech to text)
    func input(text: String)
}
