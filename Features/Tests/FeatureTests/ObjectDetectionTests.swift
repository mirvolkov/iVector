import XCTest
@testable import Features
import Features
import CoreML

final class ObjectDetectionTests: XCTestCase {
    let od = ObjectDetection()
    
    func testModel() throws {
        let bundle = Bundle.module
        let url = bundle.url(forResource: "MobileNetV2", withExtension: "mlmodelc")
        XCTAssertNotNil(url, "no model loaded")
    }
    
    func testSample() throws {
        let bundle = Bundle.module
        let url = bundle.url(forResource: "MobileNetV2", withExtension: "mlmodelc")
        XCTAssertNotNil(url, "no model loaded")
        let model = try MobileNetV2.init(contentsOf: url!)
        let image = bundle.url(forResource: "test_sample", withExtension: "jpeg")
        XCTAssertNotNil(image, "no image loaded")
        let input: MobileNetV2Input = try .init(imageAt: image!, iouThreshold: 0, confidenceThreshold: 0)
        let predict = try model.prediction(input: input)
        print(predict.featureValue(for: "confidence"))
    }
}
