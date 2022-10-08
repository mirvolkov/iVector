import Combine
import Connection
import Features
import SwiftUI
import Programmator

class ControlPanelViewModel: ObservableObject {
    lazy var buttons: [String: any ControlPanelButtonViewModel] = [
        "PWR": powerBtn,
        "DOCK": dockBtn,
        "BTN1": btn1,
        "BTN2": btn2,
        "BTN3": btn3,
        "BTN4": btn4,
        "BTN5": btn5,
        "BTN6": btn6,
        "BTN7": btn7,
        "BTN8": btn8,
        "BTN9": btn9,
        "BTN0": btn0,
        "STT": stt,
        "TTS": tts,
        "LIFT": lift,
        "PLAY": play,
        "ENTER": enter,
        "ESC": esc,
        "SAVE": save,
    ]

    lazy var powerBtn = ButtonPowerViewModel(
        connection: connection
    )
    lazy var stt = ButtonSTTViewModel(
        connection: connection,
        settings: settings
    )
    lazy var tts = ButtonTTSViewModel(
        connection: connection,
        settings: settings
    )
    lazy var dockBtn = ButtonDockViewModel(connection: connection)
    lazy var btn1 = Button1ViewModel()
    lazy var btn2 = Button2ViewModel()
    lazy var btn3 = Button3ViewModel()
    lazy var btn4 = Button4ViewModel()
    lazy var btn5 = Button5ViewModel()
    lazy var btn6 = Button6ViewModel()
    lazy var btn7 = Button7ViewModel()
    lazy var btn8 = Button8ViewModel()
    lazy var btn9 = Button9ViewModel()
    lazy var btn0 = Button0ViewModel()
    lazy var lift = ButtonLiftViewModel(connection: connection)
    lazy var play = ButtonPlayViewModel(connection: connection)
    lazy var enter = ButtonEnterViewModel(assembler: assembler)
    lazy var esc = ButtonEscViewModel(assembler: assembler)
    lazy var save = ButtonSaveViewModel(assembler: assembler)

    @Published var mode: Mode = .primary {
        didSet {
            modeButtons()
            tagButtons()
        }
    }
    @Published var showSavePopover = false
    @Published var command: String? = nil
    @Published var playPopover: Bool = false
    @Published var ttsAlert: Bool = false
    @Published var isConnected: Bool = false {
        didSet {
            onConnected()
        }
    }
    @Published var saveError: ControlPanelSaveError? = nil

    internal let connection: ConnectionModel
    internal let settings: SettingsModel
    internal let assembler: AssemblerModel
    internal var bag = Set<AnyCancellable>()

    init(_ connection: ConnectionModel, _ settings: SettingsModel, _ assembler: AssemblerModel) {
        self.settings = settings
        self.connection = connection
        self.assembler = assembler
    }
}
