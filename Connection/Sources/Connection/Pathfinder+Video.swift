// swiftlint:disable:next file_header
import AVFoundation
import CoreImage

extension PathfinderConnection: Camera {
    public func requestCameraFeed(
        with settings: VectorCameraSettings = .default
    ) async throws -> AsyncStream<VectorCameraFrame> {
        cameraSettings = settings
        return await withUnsafeContinuation { continuation in
            cameraInitContinuation = continuation
            queue.async { [weak self] in
                guard let self else {
                    return
                }
                addObservers()
                stopSession()
                setUpSession()
                setUpCamera()
                startSession()
            }
        }
    }

    func setUpSession() {
        logger.info("setting up session...")

        captureSession.inputs.forEach { input in
            captureSession.removeInput(input)
        }

        captureSession.outputs.forEach { output in
            captureSession.removeOutput(output)
        }
    }

    private func startSession() {
        if !captureSession.isRunning {
            captureSession.startRunning()
            logger.info("session did start")
        }
    }

    private func setUpCamera() {
        var types: [AVCaptureDevice.DeviceType] = []
        if #available(iOS 17.0, macOS 14.0, *) {
            types.append(.external)
            types.append(.builtInWideAngleCamera)
        } else {
            types.append(.builtInWideAngleCamera)
        }

        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: types,
            mediaType: .video,
            position: .unspecified
        )

        logger.info("cameras: \(discoverySession.devices)")

        guard let camera = discoverySession.devices.first(where: { $0.uniqueID == cameraSettings?.deviceID }) else {
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
#if os(iOS)
            videoOutput.connection(with: AVMediaType.video)?.videoRotationAngle = .init(cameraSettings?.rotation ?? 0)
#else
            videoOutput.connection(with: AVMediaType.video)?.videoRotationAngle = .init(cameraSettings?.rotation ?? 0)
#endif
        }

        captureSession.commitConfiguration()
        logger.info("camera did start!")

        cameraInitContinuation?.resume(with: .success(.init { continuation in
            self.cameraFeedContinuation = continuation
        }))
        cameraInitContinuation = nil
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

    // swiftlint:disable block_based_kvo
    // swiftlint:disable override_in_extension
    public override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == "systemPreferredCamera" {
            if let systemPreferredCamera = change?[.newKey] as? AVCaptureDevice,
               systemPreferredCamera.uniqueID == cameraSettings?.deviceID {
                logger.info("external systemPreferredCamera set to \(systemPreferredCamera)")
                queue.async { [weak self] in
                    guard let self else { 
                        return
                    }
                    stopSession()
                    setUpSession()
                    startCamera(systemPreferredCamera)
                    startSession()
                }
            }
        }
    }
    // swiftlint:enable block_based_kvo
    // swiftlint:enable override_in_extension

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
