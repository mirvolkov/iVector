import XCTest
import Foundation
import SwiftUI
@testable import Components

final class HeadControlTests: XCTestCase, HeadControlTools {
    func testConverters() {
        XCTAssertEqual(degreeToNorm(-22), 0)
        XCTAssertEqual(degreeToNorm(45), 100)
        XCTAssertEqual(normToDegree(0), -22)
        XCTAssertEqual(normToDegree(100), 45)
    }

    func testCycle() {
        let angle = Angle(degrees: 45).radians
        let degrees = Angle.init(radians: angle).degrees
        let headAngle = degreeToNorm(degrees)
        let degreesR = normToDegree(headAngle)
        XCTAssertEqual(Double(degreesR), degrees)
    }
}
