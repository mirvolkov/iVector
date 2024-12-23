import Foundation
import GRPC
import NIO
import SwiftProtobuf

extension VectorConnection: Behavior {
    private static let firstSDKTag: Int32 = 2_000_001

    public func setHeadAngle(_ angle: Float) async throws {
        var request: Anki_Vector_ExternalInterface_SetHeadAngleRequest = .init()
        request.angleRad = angle * Float.pi / 180.0
        request.accelRadPerSec2 = 10
        request.maxSpeedRadPerSec = 10
        request.idTag = VectorConnection.firstSDKTag
        let call: UnaryCall<Anki_Vector_ExternalInterface_SetHeadAngleRequest,
            Anki_Vector_ExternalInterface_SetHeadAngleResponse> = connection.makeUnaryCall(
            path: "\(prefixURI)SetHeadAngle",
            request: request,
            callOptions: callOptions
        )

        return try await withCheckedThrowingContinuation { continuation in
            call.response.whenSuccess { _ in
                continuation.resume(returning: ())
            }
            call.response.whenFailure { error in
                continuation.resume(throwing: error)
            }
        }
    }

    public func lift(_ height: Float) async throws {
        let minHeight: Float = 32.0
        let maxHeight: Float = 92.0
        var request: Anki_Vector_ExternalInterface_SetLiftHeightRequest = .init()
        request.heightMm = Float(minHeight + (height * (maxHeight - minHeight)))
        request.accelRadPerSec2 = 10
        request.maxSpeedRadPerSec = 10
        request.idTag = VectorConnection.firstSDKTag
        let call: UnaryCall<Anki_Vector_ExternalInterface_SetLiftHeightRequest,
            Anki_Vector_ExternalInterface_SetLiftHeightResponse> = connection.makeUnaryCall(
            path: "\(prefixURI)SetLiftHeight",
            request: request,
            callOptions: callOptions
        )

        return try await withCheckedThrowingContinuation { continuation in
            call.response.whenSuccess { _ in
                continuation.resume(returning: ())
            }
            call.response.whenFailure { error in
                continuation.resume(throwing: error)
            }
        }
    }

    public func say(text: String) async throws {
        var request: Anki_Vector_ExternalInterface_SayTextRequest = .init()
        request.text = text
        request.useVectorVoice = true
        request.durationScalar = 1.0
        let call: UnaryCall<Anki_Vector_ExternalInterface_SayTextRequest,
            Anki_Vector_ExternalInterface_SayTextResponse> = connection.makeUnaryCall(
            path: "\(prefixURI)SayText",
            request: request,
            callOptions: callOptions
        )
        return try await withCheckedThrowingContinuation { continuation in
            call.response.whenSuccess { _ in
                continuation.resume(returning: ())
            }
            call.response.whenFailure { error in
                continuation.resume(throwing: error)
            }
        }
    }

    public func setEyeColor(_ hue: Float, _ sat: Float) async throws {
        var eyeColorRequest = Anki_Vector_ExternalInterface_SetEyeColorRequest()
        eyeColorRequest.hue = hue
        eyeColorRequest.saturation = sat
        let call: UnaryCall<Anki_Vector_ExternalInterface_SetEyeColorRequest,
            Anki_Vector_ExternalInterface_SetEyeColorResponse> = connection.makeUnaryCall(
            path: "\(prefixURI)SetEyeColor",
            request: eyeColorRequest,
            callOptions: callOptions
        )

        return try await withCheckedThrowingContinuation { continuation in
            call.response.whenSuccess { _ in
                continuation.resume(returning: ())
            }
            call.response.whenFailure { error in
                continuation.resume(throwing: error)
            }
        }
    }

    /// set_screen_with_image_data expected 35328 bytes - (2 bytes each for 17664 pixels)
    /// The screen is 184 x 96 color (RGB565) pixels.
    public func oled(with data: Data) async throws {
        var request = Anki_Vector_ExternalInterface_DisplayFaceImageRGBRequest()
        request.faceData = data
        request.interruptRunning = true

        let call: UnaryCall<Anki_Vector_ExternalInterface_DisplayFaceImageRGBRequest,
            Anki_Vector_ExternalInterface_DisplayFaceImageRGBResponse> = connection.makeUnaryCall(
            path: "\(prefixURI)DisplayFaceImageRGB",
            request: request,
            callOptions: callOptions
        )

        return try await withCheckedThrowingContinuation { continuation in
            call.response.whenSuccess { result in
                continuation.resume(returning: ())
            }
            call.response.whenFailure { error in
                continuation.resume(throwing: error)
            }
        }
    }

    public func move(_ distance: Float, speed: Float, animate: Bool) async throws {
        var request: Anki_Vector_ExternalInterface_DriveStraightRequest = .init()
        request.distMm = distance
        request.speedMmps = speed
        request.shouldPlayAnimation = animate
        request.idTag = VectorConnection.firstSDKTag
        let call: UnaryCall<Anki_Vector_ExternalInterface_DriveStraightRequest,
            Anki_Vector_ExternalInterface_DriveStraightResponse> = connection.makeUnaryCall(
            path: "\(prefixURI)DriveStraight",
            request: request,
            callOptions: callOptions
        )
        return try await withCheckedThrowingContinuation { continuation in
            call.response.whenSuccess { _ in
                continuation.resume(returning: ())
            }
            call.response.whenFailure { error in
                continuation.resume(throwing: error)
            }
        }
    }

    public func turn(_ angle: Float, speed: Float, accel: Float, angleTolerance: Float) async throws {
        var request: Anki_Vector_ExternalInterface_TurnInPlaceRequest = .init()
        request.angleRad = angle * Float.pi / 180.0
        request.speedRadPerSec = speed
        request.accelRadPerSec2 = accel
        request.tolRad = angleTolerance
        request.idTag = VectorConnection.firstSDKTag
        let call: UnaryCall<Anki_Vector_ExternalInterface_TurnInPlaceRequest,
            Anki_Vector_ExternalInterface_TurnInPlaceResponse> = connection.makeUnaryCall(
            path: "\(prefixURI)TurnInPlace",
            request: request,
            callOptions: callOptions
        )
        return try await withCheckedThrowingContinuation { continuation in
            call.response.whenSuccess { _ in
                continuation.resume(returning: ())
            }
            call.response.whenFailure { error in
                continuation.resume(throwing: error)
            }
        }
    }

    public func driveOnCharger() async throws {
        let request: Anki_Vector_ExternalInterface_DriveOnChargerRequest = .init()
        let call: UnaryCall<Anki_Vector_ExternalInterface_DriveOnChargerRequest,
            Anki_Vector_ExternalInterface_DriveOnChargerResponse> = connection.makeUnaryCall(
            path: "\(prefixURI)DriveOnCharger",
            request: request,
            callOptions: callOptions
        )
        return try await withCheckedThrowingContinuation { continuation in
            call.response.whenSuccess { _ in
                continuation.resume(returning: ())
            }
            call.response.whenFailure { error in
                continuation.resume(throwing: error)
            }
        }
    }

    public func driveOffCharger() async throws {
        let request: Anki_Vector_ExternalInterface_DriveOffChargerRequest = .init()
        let call: UnaryCall<Anki_Vector_ExternalInterface_DriveOffChargerRequest,
            Anki_Vector_ExternalInterface_DriveOffChargerResponse>
            = connection.makeUnaryCall(
                path: "\(prefixURI)DriveOffCharger",
                request: request,
                callOptions: callOptions
            )

        return try await withCheckedThrowingContinuation { continuation in
            call.response.whenSuccess { _ in
                continuation.resume(returning: ())
            }
            call.response.whenFailure { error in
                continuation.resume(throwing: error)
            }
        }
    }

    public var battery: VectorBatteryState {
        get async throws {
            let request: Anki_Vector_ExternalInterface_BatteryStateRequest = .init()
            let call: UnaryCall<Anki_Vector_ExternalInterface_BatteryStateRequest,
                Anki_Vector_ExternalInterface_BatteryStateResponse>
                = connection.makeUnaryCall(
                    path: "\(prefixURI)BatteryState",
                    request: request,
                    callOptions: callOptions
                )

            return try await withCheckedThrowingContinuation { continuation in
                call.response.whenSuccess { result in
                    if result.isCharging {
                        continuation.resume(returning: .charging)
                    } else {
                        continuation.resume(returning: .init(with: result.batteryLevel))
                    }
                }
                call.response.whenFailure { error in
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func requestEventStream() throws {
        var request: Anki_Vector_ExternalInterface_EventRequest = .init()
        request.connectionID = UUID()
            .uuidString
            .replacingOccurrences(of: "-", with: "")
            .lowercased()

        eventStream = connection.makeBidirectionalStreamingCall(
            path: "\(prefixURI)EventStream",
            callOptions: callOptions
        ) { [weak self] message in
            if message.hasEvent {
                switch message.event.eventType {
                case .robotState(let state):
                    self?.delegate?.onRobot(state: state)

                default:
                    break
                }
            }
        }

        _ = eventStream?.sendMessage(request)
    }
}
