import AVFoundation
import CoreImage

extension PathfinderConnection: Camera {
    public func requestCameraFeed() throws -> AsyncStream<VectorCameraFrame> {
        addObservers()
        setUpSession()
        setUpCamera()
        startSession()

        return .init { continuation in
            self.cameraFeedContinuation = continuation
        }
    }

    func setUpSession() {
        logger.info("setting up session...")
        stopSession()

        captureSession.inputs.forEach { input in
            captureSession.removeInput(input)
        }

        captureSession.outputs.forEach { output in
            captureSession.removeOutput(output)
        }
    }

    private func startSession() {
        queue.async { [self] in
            if !captureSession.isRunning {
                captureSession.startRunning()
                logger.info("session did start")
            }
        }
    }

    private func setUpCamera() {
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

        logger.info("cameras: \(discoverySession.devices)")

        guard let camera = discoverySession.devices.first else {
            return
        }

        startCamera(camera)
    }

    private func startCamera(_ externalCameraDevice: AVCaptureDevice) {
        logger.info("starting camera...")
        captureSession.beginConfiguration()

        guard let videoInput = try? AVCaptureDeviceInput(device: externalCameraDevice) else {
            return
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

        if #available(iOS 17.0, macOS 14.0, *) {
            videoOutput.connection(with: AVMediaType.video)?.videoRotationAngle = 90
        }

        captureSession.commitConfiguration()
        logger.info("camera did start!")
    }

    private func stopSession() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sessionRuntimeError),
            name: .AVCaptureSessionRuntimeError,
            object: captureSession
        )

        AVCaptureDevice.self.addObserver(self, forKeyPath: "systemPreferredCamera", options: [.new], context: nil)
    }

    public override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == "systemPreferredCamera" {
            if let systemPreferredCamera = change?[.newKey] as? AVCaptureDevice,
               systemPreferredCamera.deviceType == .external {
                logger.info("external systemPreferredCamera set to \(systemPreferredCamera)")
                setUpSession()
                startCamera(systemPreferredCamera)
                startSession()
            } else {
                logger.info("external systemPreferredCamera dropped")
                stopSession()
            }
        }
    }

    /// - Tag: HandleRuntimeError
    @objc
    func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else {
            return
        }

        logger.fault("Capture session runtime error: \(error)")
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
