/// Synching: save and load
public protocol ProgrammatorSync {
    /// Saves current program. Empties program stack
    /// - Throws alreadyExists error if name overlaps existing name
    func save(name: String) throws
}

