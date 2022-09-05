//
//  File.swift
//
//
//  Created by Miroslav Volkov on 31.08.2022.
//

import Combine
import CoreML
import os.log
import Vision

public final class ObjectDetection {
    @Published public var objects: PassthroughSubject<[VNRecognizedObjectObservation], Never> = .init()
    private lazy var requestOptions: [VNImageOption: Any] = [:]
    private lazy var requests: [VNRequest] = [visionRequest]
    private let logger = Logger(subsystem: "com.mirfirstsnow.ivector", category: "main")
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
            print(error)
        }
    }

    public func process(_ data: Data) {
        do {
            let imageRequestHandler = VNImageRequestHandler(data: data, options: requestOptions)
            try imageRequestHandler.perform(requests)
        } catch {
            print(error)
        }
    }
}
