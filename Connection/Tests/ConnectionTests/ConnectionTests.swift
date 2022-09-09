import XCTest
@testable import Connection

final class ConnectionTests: XCTestCase {
    func testExample() throws {
        let connection: Connection? = VectorConnection(with: "192.168.0.105", port: 443)
        XCTAssertNotNil(connection, "Connection init failed")
    }
}
