// swiftlint:disable:next file_header
import Combine
import CoreImage
import CoreML
import os.log
import Vision

/// Object detector with MobileNetV2 background
public final class ObjectDetection {
    /// Reactive subject with detected objects stream
    @Published public var objects: PassthroughSubject<[VNRecognizedObjectObservation], Never> = .init()

    private lazy var logger = Logger(subsystem: "com.mirfirstsnow.ivector", category: "main")
    private lazy var requestOptions: [VNImageOption: Any] = [:]
    private lazy var requests: [VNRequest] = [visionRequest]
    private lazy var movileNetV2: VNCoreMLModel = {
        do {
            let model = try MobileNetV2(configuration: .init()).model
            return try VNCoreMLModel(for: model)
        } catch {
            fatalError("Failed to create VNCoreMLModel: \(error)")
        }
    }()

    private lazy var visionRequest: VNCoreMLRequest = {
        let request = VNCoreMLRequest(model: movileNetV2, completionHandler: { [weak self] request, _ in
            if let results = request.results as? [VNRecognizedObjectObservation], !results.isEmpty, let self = self {
                self.objects.send(results)
            }
        })
        request.imageCropAndScaleOption = .scaleFill
        return request
    }()

    public init() {}

    public func process(_ buffer: CVPixelBuffer) {
        do {
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: buffer, options: requestOptions)
            try imageRequestHandler.perform(requests)
        } catch {
            logger.error("OD \(error.localizedDescription)")
        }
    }

    public func process(_ data: Data) {
        do {
            let imageRequestHandler = VNImageRequestHandler(data: data, options: requestOptions)
            try imageRequestHandler.perform(requests)
        } catch {
            logger.error("OD \(error.localizedDescription)")
        }
    }

    public func process(_ image: CIImage) {
        do {
            let imageRequestHandler = VNImageRequestHandler(ciImage: image, options: requestOptions)
            try imageRequestHandler.perform(requests)
        } catch {
            logger.error("OD \(error.localizedDescription)")
        }
    }
}
