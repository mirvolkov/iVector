import Combine
import Connection
import Features
import SwiftUI
import Programmator

class ControlPanelViewModel: ObservableObject {
    lazy var powerBtn = ButtonPowerViewModel(connection: connection)
    lazy var tts = ButtonTTSViewModel(assembler: assembler)
    lazy var dockBtn = ButtonDockViewModel()
    lazy var undockBtn = ButtonUndockViewModel()
    lazy var btn1 = Button1ViewModel()
    lazy var btn2 = Button2ViewModel()
    lazy var btn3 = Button3ViewModel()
    lazy var btn4 = Button4ViewModel()
    lazy var btn5 = Button5ViewModel()
    lazy var btn6 = Button6ViewModel()
    lazy var btn7 = Button7ViewModel(assembler: assembler)
    lazy var btn8 = Button8ViewModel(assembler: assembler)
    lazy var btn9 = Button9ViewModel(assembler: assembler)
    lazy var btn0 = Button0ViewModel(assembler: assembler)
    lazy var lift = ButtonLiftViewModel()
    lazy var down = ButtonDownViewModel()
    lazy var play = ButtonPlayViewModel(assembler: assembler)
    lazy var enter = ButtonEnterViewModel(assembler: assembler)
    lazy var esc = ButtonEscViewModel(assembler: assembler)
    lazy var save = ButtonSaveViewModel(assembler: assembler)
    lazy var pause = ButtonPauseViewModel()
    lazy var exec = ButtonExecViewModel(assembler: assembler)

    @Published var mode: Mode = .primary {
        didSet {
            modeButtons()
            tagButtons()
        }
    }

    @Published var showVisionObjects: Bool = false
    @Published var showTextRequest: Bool = false
    @Published var showPrograms: Bool = false
    @Published var showSavePopover = false
    @Published var command: String? = nil
    @Published var playPopover: Bool = false
    @Published var ttsAlert: Bool = false
    @Published var isConnected: Bool = false {
        didSet {
            onConnected()
        }
    }
    @Published var saveError: ErrorHandlerViewModel? = nil

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
