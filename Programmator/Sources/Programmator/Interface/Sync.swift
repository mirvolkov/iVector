import Foundation

/// Synching
public protocol ProgrammatorSync {
    /// Programs storage location
    var progStorageName: String { get }

    /// Program file extension
    var progFileExtension: String { get }

    /// Gets documents directory + location storage
    func progLocation() throws -> URL
}

/// Synching: save
public protocol ProgrammatorSave: ProgrammatorSync {
    /// Saves current program. Empties program stack
    /// - Throws alreadyExists error if name overlaps existing name
    func save(name: String) throws
}

/// Synching: load
public protocol ProgrammatorLoad: ProgrammatorSync {
    /// List of programs
    var programs: [Program] { get throws }
}

public extension ProgrammatorSync {
    func progLocation() throws -> URL {
        let location = try FileManager
            .default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(progStorageName)
        
        if !FileManager.default.fileExists(atPath: location.path) {
            try FileManager.default.createDirectory(atPath: location.path, withIntermediateDirectories: true, attributes: nil)
        }

        return location
    }
    
    var progStorageName: String {
        "Programs"
    }
    
    var progFileExtension: String {
        "json"
    }
}
