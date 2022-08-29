import XCTest
@testable import Connection

final class ConnectionTests: XCTestCase {
    func testExample() throws {
        let connection = VectorConnection()
        try connection.open(with: "", port: 123)
        XCTAssertEqual(connection.cert, "Hello, World!")
    }
}
