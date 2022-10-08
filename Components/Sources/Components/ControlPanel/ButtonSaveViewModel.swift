import Combine
import Features
import SwiftUI
import Programmator

class ButtonSaveViewModel: ControlPanelButtonViewModel, TextFieldPopoverCallback {
    @Published var disableSecondary: Bool = false
    @Published var disableTitle: Bool = false
    @Published var disableIcon: Bool = false
    @Published var enabled: Bool = true
    @Published var primaryIcon: Image?
    @Published var primaryTitle: String?
    @Published var secondaryTitle: String?
    @Published var tintColor: Color = .green
    @Published var tag: CPViewModelTag?
    @Published var showSavePopover = false

    private let assembler: AssemblerModel
    private var bag = Set<AnyCancellable>()

    init(assembler: AssemblerModel) {
        self.primaryIcon = .init(systemName: "externaldrive.badge.plus")
        self.tintColor = .black
        self.enabled = false
        self.assembler = assembler
    }

    func bind() {
        assembler.$program
            .map { "#\($0.count)" }
            .assign(to: \.primaryTitle, on: self)
            .store(in: &bag)

        assembler.$program
            .map { $0.count > 0 }
            .assign(to: \.enabled, on: self)
            .store(in: &bag)
    }

    func onClick() {
        showSavePopover = true
    }
    
    func onTextChange(text: String) {
        showSavePopover = false
    }
}
