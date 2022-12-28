import Foundation

/// Synching
public protocol ProgrammatorSync {
    /// Programs storage location
    static var progStorageName: String { get }

    /// Program file extension
    static var progFileExtension: String { get }

    /// Gets documents directory + location storage
    static func progLocation() throws -> URL
}

/// Synching: save
public protocol ProgrammatorSave: ProgrammatorSync {
    /// List of programs
    static var programs: [Program] { get async throws }

    /// Saves current program. Empties program stack
    /// - Throws alreadyExists error if name overlaps existing name
    func save(name: String) throws

    /// Delete  program.
    /// - Throws fs error
    func delete(name: String) throws
}

/// Synching: load
public protocol ProgrammatorLoad: ProgrammatorSync {
    /// List of programs
    var programs: [Program] { get throws }
}

public extension ProgrammatorSync {
    static func progLocation() throws -> URL {
        let location = URL
            .documentsDirectory
            .appending(path: progStorageName)
        
        if !FileManager.default.fileExists(atPath: location.path) {
            try FileManager.default.createDirectory(atPath: location.path, withIntermediateDirectories: true, attributes: nil)
        }

        return location
    }
    
    static var progStorageName: String {
        "Programs"
    }
    
    static var progFileExtension: String {
        "json"
    }
}

public extension ProgrammatorSync {
    static var programs: [Program] {
        get async throws {
            let path = try Self.progLocation()
            let content = try FileManager.default
                .contentsOfDirectory(
                    at: path,
                    includingPropertiesForKeys: nil
                )
            return content.map { Program.init(url: $0) }
        }
    }
}
