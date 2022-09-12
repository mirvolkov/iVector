import XCTest
@testable import Connection

final class DataAccumulatorTests: XCTestCase {
    var acc: DataAccumulator!
    
    override func setUp() {
        acc = DataAccumulator()
    }
    
    func testInit() async {
        let value = await acc.get()
        XCTAssertEqual(value.count, 0)
    }
    
    func testPush() async {
        let data: Data = "abracadabra".data(using: .utf8)!
        let size = data.count
        await acc.push(data)
        let chunk = await acc.pop(size)
        XCTAssertEqual(data.count, chunk.count)
    }
    
    func testPop() async {
        let data: Data = "abracadabra".data(using: .utf8)!
        let size = data.count
        await acc.push(data)
        _ = await acc.pop(size)
        let rest = await acc.pop(size)
        XCTAssertEqual(rest.count, 0)
    }
}
