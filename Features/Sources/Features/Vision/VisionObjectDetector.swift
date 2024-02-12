// swiftlint:disable:next file_header
import Combine
import CoreImage
import CoreML
import os.log
import Vision

/// Object detector with MobileNetV2 background
public final class VisionObjectDetector {
    /// Reactive subject with detected objects stream
    @Published public var objects: PassthroughSubject<[VNRecognizedObjectObservation], Never> = .init()

    /// Reactive subject with detected objects stream
    @Published public var track: PassthroughSubject<VNDetectedObjectObservation?, Never> = .init()

    /// Reactive subject with detected QRs stream
    @Published public var barcodes: PassthroughSubject<[VNBarcodeObservation], Never> = .init()

    public var trackingLevel = VNRequestTrackingLevel.accurate

    private lazy var logger = Logger(subsystem: "com.mirfirstsnow.ivector", category: "main")
    private lazy var requestOptions: [VNImageOption: Any] = [:]
    private lazy var requests: [VNRequest] = [visionRequest, barcodeNativeScanner]
    private lazy var movileNetV2: VNCoreMLModel = {
        do {
//            let model = try MobileNetV2(configuration: .init()).model
            let model = try YOLO8s(configuration: .init()).model
            return try VNCoreMLModel(for: model)
        } catch {
            fatalError("Failed to create VNCoreMLModel: \(error)")
        }
    }()

    private lazy var barcodeNativeScanner: VNDetectBarcodesRequest = {
        let barcodeRequest = VNDetectBarcodesRequest { [weak self] request, _ in
            if let results = request.results as? [VNBarcodeObservation], !results.isEmpty {
                self?.barcodes.send(results)
            }
        }
        return barcodeRequest
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

    private lazy var sequenceRequestHandler = VNSequenceRequestHandler()
    private var lastObservation: VNDetectedObjectObservation?

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

    public func track(_ image: CIImage, for observation: VNDetectedObjectObservation) {
        guard let lastObservation else {
            self.lastObservation = observation
            return
        }

        autoreleasepool {
            do {
                let request = VNTrackObjectRequest(
                    detectedObjectObservation: lastObservation,
                    completionHandler: handleVisionRequestUpdate
                )
                request.trackingLevel = trackingLevel
                try sequenceRequestHandler.perform([request], on: image)
            } catch let error as NSError {
                NSLog("Failed to perform SequenceRequest: %@", error)
            }
        }
    }
}

extension VisionObjectDetector {
    private func handleVisionRequestUpdate(_ request: VNRequest, error: Error?) {
        guard let trackResult = request.results?
            .compactMap({ $0 as? VNDetectedObjectObservation })
            .filter({ $0.confidence > 0.5 })
            .first
        else {
            self.lastObservation = nil
            self.track.send(nil)
            return
        }

        track.send(trackResult)
        self.lastObservation = trackResult
    }
}
