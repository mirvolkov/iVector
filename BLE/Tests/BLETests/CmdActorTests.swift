import XCTest
@testable import BLE

class BLEIOMock: BLEIO {
    var callbacks: [BLE.Callback] = []
    let queue = DispatchQueue.global()
    
    func listen(for charID: String, callback: @escaping BLE.Callback) {
        self.callbacks.append(callback)
    }
    
    func write(data: Data, charID: String) {
        if let cmd = String(data: data, encoding: .ascii) {
            print("mock write on cmd \(cmd)")
            queue.asyncAfter(deadline: .now() + 0.5) {
                print("mock read on cmd \(cmd)")
                self.callbacks.forEach { $0(cmd) }
            }
        }
    }
}

final class BLETests: XCTestCase {
    let cmd = Commander(with: BLEIOMock(), txID: "01", rxID: "02")

    func test2() async throws {
        Task {
            let result = try await self.cmd.run(cmd: "test1")
            XCTAssertEqual(result, "test1")
        }
        Task {
            let result = try await cmd.run(cmd: "test2")
            XCTAssertEqual(result, "test2")
        }
        let cmd3 = try await cmd.run(cmd: "test3")
        XCTAssertEqual(cmd3, "test2")
    }
}
