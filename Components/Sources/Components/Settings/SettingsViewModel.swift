import AVKit
import Combine
import Features
import SwiftUI

extension SettingsView {
    struct CameraDevice: Hashable, Identifiable {
        let id: String
        let name: String
    }

    class ViewModel: ObservableObject {
        @Published public var vectorIP: String = ""
        @Published public var websocketIP: String = ""
        @Published public var eyeColor: Color = .white
        @Published public var isValid: Bool = false
        @Published public var locale: String = "en"
        @Published public var certPath: URL? = nil
        @Published public var guid: String? = nil
        @Published public var cameraID: String = ""
        @Published public var rotID: Int = 0
        @Published public var decimation: Int = 1
        
        private let model: SettingsModel
        private var bag = Set<AnyCancellable>()
        private let regex = "^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$"
        private let invalidCharacters = CharacterSet(charactersIn: ".0123456789").inverted

        lazy var cameras: [CameraDevice] = {
            getListOfCameras().map {
                .init(id: $0.uniqueID, name: $0.localizedName)
            }
        }()

        init(_ model: SettingsModel) {
            self.model = model
            self.vectorIP = trimInvalidCharacters(model.vectorIP)
            self.websocketIP = trimInvalidCharacters(model.websocketIP)
            self.eyeColor = model.eyeColor
            self.locale = model.locale
            self.cameraID =  model.cameraID ?? ""
            self.rotID = model.cameraROT
            self.decimation = model.decimation
        }

        @MainActor func save() {
            model.vectorIP = vectorIP
            model.websocketIP = websocketIP
            model.eyeColor = eyeColor
            model.locale = locale
            model.cameraID = cameraID
            model.cameraROT = rotID
            model.decimation = decimation
        }

        func validate() {
            isValid = vectorIP.range(of: regex, options: .regularExpression) != nil &&
                websocketIP.range(of: regex, options: .regularExpression) != nil
        }

        func trimInvalidCharacters(_ source: String) -> String {
            source
                .components(separatedBy: invalidCharacters)
                .joined()
        }
    }
}

extension SettingsView.ViewModel {
    /// Returns all cameras on the device.
    fileprivate func getListOfCameras() -> [AVCaptureDevice] {
        #if os(iOS)
            var types: [AVCaptureDevice.DeviceType] = []
            if #available(iOS 17.0, macOS 14.0, *) {
                types.append(.external)
                types.append(.builtInWideAngleCamera)
                types.append(.builtInTelephotoCamera)
            } else {
                types.append(.builtInWideAngleCamera)
            }
            let session = AVCaptureDevice.DiscoverySession(
                deviceTypes: types,
                mediaType: .video,
                position: .unspecified)
            return session.devices
        #elseif os(macOS)
            let session = AVCaptureDevice.DiscoverySession(
                deviceTypes: [
                    .external,
                    .builtInWideAngleCamera
                ],
                mediaType: .video,
                position: .unspecified)
            return session.devices
        #endif
    }
}
