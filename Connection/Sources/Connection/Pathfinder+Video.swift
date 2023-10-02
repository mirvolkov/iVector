import AVFoundation
import CoreImage

extension PathfinderConnection: Camera {
    public func requestCameraFeed() throws -> AsyncStream<VectorCameraFrame> {
        try setUp()

        return .init { continuation in
            self.cameraFeedContinuation = continuation
        }
    }

    func setUp() throws {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }

        captureSession.inputs.forEach { input in
            captureSession.removeInput(input)
        }

        captureSession.outputs.forEach { output in
            captureSession.removeOutput(output)
        }

        captureSession.beginConfiguration()

        defer {
            captureSession.commitConfiguration()
            if !captureSession.isRunning {
                captureSession.startRunning()
            }
        }

        try setUpCamera()
    }

    func setUpCamera() throws {
        var types: [AVCaptureDevice.DeviceType] = []
        if #available(iOS 17.0, macOS 14.0, *) {
            types.append(.external)
        } else {
            types.append(.builtInWideAngleCamera)
        }

        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: types,
            mediaType: .video,
            position: .unspecified
        )

        guard let externalCameraDevice = discoverySession.devices.first else {
            throw PathfinderError.cameraFailed
        }

        guard let videoInput = try? AVCaptureDeviceInput(device: externalCameraDevice) else {
            throw PathfinderError.cameraFailed
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }

        let settings: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA)
        ]

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.videoSettings = settings
        videoOutput.alwaysDiscardsLateVideoFrames = true
        #if os(iOS)
            videoOutput.automaticallyConfiguresOutputBufferDimensions = true
        #endif
        videoOutput.setSampleBufferDelegate(self, queue: queue)

        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }

        logger.info("EXTERNAL CAMERA INIT COMPLETED")
        if #available(iOS 17.0, macOS 14.0, *) {
            videoOutput.connection(with: AVMediaType.video)?.videoRotationAngle = 90
        }
    }
}

extension PathfinderConnection: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        if let videoFrame = CMSampleBufferGetImageBuffer(sampleBuffer) {
            cameraFeedContinuation?.yield(.init(
                image: .init(cvPixelBuffer: videoFrame)
            ))
        }
    }

    public func captureOutput(
        _ output: AVCaptureOutput,
        didDrop sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        logger.fault("frame dropped")
    }
}
