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

    func setUpCamera(
        sessionPreset: AVCaptureSession.Preset = .low,
        deviceID: String? = AVCaptureDevice.default(for: AVMediaType.video)?.uniqueID
    ) throws {
        if captureSession.canSetSessionPreset(sessionPreset) {
            captureSession.sessionPreset = sessionPreset
        }

        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInMicrophone, .builtInWideAngleCamera],
            mediaType: .video,
            position: .unspecified
        )

        guard let cameraDevice = discoverySession.devices.first(where: { $0.uniqueID == deviceID }) else {
            throw PathfinderError.cameraFailed
        }

        guard let videoInput = try? AVCaptureDeviceInput(device: cameraDevice) else {
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

        videoOutput.connection(with: AVMediaType.video)?.videoOrientation = .portrait
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

public extension Pathfinder {
    /// Returns all cameras on the device.
    static func getListOfCameras() -> [AVCaptureDevice] {
        #if os(iOS)
            return AVCaptureDevice.DiscoverySession(
                deviceTypes: [
                    //                .external,
                    .builtInWideAngleCamera,
                    .builtInTelephotoCamera
                ],
                mediaType: .video,
                position: .unspecified
            )
            .devices
        #elseif os(macOS)
            return AVCaptureDevice.DiscoverySession(
                deviceTypes: [
                    .builtInWideAngleCamera
                ],
                mediaType: .video,
                position: .unspecified
            )
            .devices
        #endif
    }

    /// Returns all microphones on the device.
    static func getListOfMicrophones() -> [AVCaptureDevice] {
        let session = AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInMicrophone
            ],
            mediaType: .audio,
            position: .unspecified
        )

        return session.devices
    }

    /// Converts giving AVCaptureDevice list to the String
    static func convertDeviceListToString(_ devices: [AVCaptureDevice]) -> [String] {
        return devices.map { $0.localizedName }
    }

    static func getListOfCamerasAsString() -> [String] {
        return convertDeviceListToString(getListOfCameras())
    }

    static func getListOfMicrophonesAsString() -> [String] {
        return convertDeviceListToString(getListOfMicrophones())
    }
}
