import Combine
import Features
import SwiftUI

class ButtonSTTViewModel: ControlPanelButtonViewModel {
    @Published var disableSecondary: Bool = false
    @Published var disableTitle: Bool = false
    @Published var disableIcon: Bool = false
    @Published var enabled: Bool = true
    @Published var primaryIcon: Image?
    @Published var primaryTitle: String?
    @Published var secondaryTitle: String?
    @Published var tintColor: Color = .green
    @Published var isLoading: Bool = false

    private var stt: SpeechToText?
    private let settings: SettingsModel
    private let connection: ConnectionModel
    private var bag = Set<AnyCancellable>()

    init(connection: ConnectionModel, settings: SettingsModel) {
        self.connection = connection
        self.settings = settings
        self.primaryIcon = .init(systemName: "mic")
        self.tintColor = .mint
    }
    
    func onClick() {
#if os(iOS)
        self.stt = SpeechToText(with: AudioSession())
#elseif os(macOS)
        Task {
            self.stt = SpeechToText(with: VectorSource(with: try await connection.mic!))
        }
#endif
        
        stt?.start()
    }
}
