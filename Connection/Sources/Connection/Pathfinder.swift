import AVFoundation
import BLE
import Combine
import CoreImage
import OSLog

public struct PFSonar {
    public var sonar1: UInt
    public var sonar2: UInt
    public var sonar3: UInt
    public var sonar4: UInt

    public static var zero: Self { .init(sonar1: 0, sonar2: 0, sonar3: 0, sonar4: 0) }
}

public enum PathfinderError: Error {
    case notConnected
    case cameraFailed
}

/**
 Pathfinder connection protocol
 Camera, gyroscope and mic are - build-in
 Sonar and other peripherals connected to pathfinder through BLE
 */
public protocol Pathfinder {
    var online: CurrentValueSubject<Bool, Never> { get }
    var sonar: PassthroughSubject<PFSonar, Never> { get }
    var current: PassthroughSubject<Int, Never> { get }

    func connect() async throws
    func disconnect()
}

public final class PathfinderConnection: NSObject, Pathfinder {
    private let logger = Logger(subsystem: "com.mirfirstsnow.ivector", category: "pathfinder")
    private let ble: BLE
    private var bag = Set<AnyCancellable>()
    private var onlineContinuation: CheckedContinuation<Void, Error>?
    private var cameraFeedContinuation: AsyncStream<VectorCameraFrame>.Continuation?
    private let captureSession = AVCaptureSession()
    private let queue = DispatchQueue(label: "pathfinder.camera")

    public var online: CurrentValueSubject<Bool, Never> = .init(false)
    public var sonar: PassthroughSubject<PFSonar, Never> = .init()
    public var current: PassthroughSubject<Int, Never> = .init()

    public init(with bleID: String) {
        ble = BLE([bleID])
        super.init()
        ble.$isOnline.sink { [weak self] online in
            self?.online.value = online
            if let continuation = self?.onlineContinuation, online {
                continuation.resume()
            }
        }.store(in: &bag)
    }

    public func connect() async throws {
        ble.scan()

        guard !online.value else {
            return
        }

        try await withCheckedThrowingContinuation { continuation in
            self.onlineContinuation = continuation
        }
    }

    public func disconnect() {
        online.value = false
        captureSession.stopRunning()
        onlineContinuation = nil
    }
}

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
