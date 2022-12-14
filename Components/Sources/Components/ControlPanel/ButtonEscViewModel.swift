import Combine
import SwiftUI
import Programmator

class ButtonEscViewModel: ControlPanelButtonViewModel {
    @Published var disableSecondary: Bool = false
    @Published var disableTitle: Bool = false
    @Published var disableIcon: Bool = false
    @Published var enabled: Bool = true
    @Published var primaryIcon: Image?
    @Published var primaryTitle: String?
    @Published var secondaryTitle: String?
    @Published var tintColor: Color = .green
    @Published var onEsc: Bool = false
    @Published var tag: CPViewModelTag?

    private let assembler: AssemblerModel
    private var bag = Set<AnyCancellable>()

    init(assembler: AssemblerModel) {
        self.primaryIcon = .init(systemName: "delete.backward")
        self.primaryTitle = "Esc"
        self.assembler = assembler
    }

    func bind() {
        assembler.$program
            .compactMap { $0.count > 0 }
            .combineLatest(assembler.$current.map { $0 != nil})
            .map { $0.0 || $0.1 }
            .assign(to: \.enabled, on: self)
            .store(in: &bag)
    }

    func onClick() {
        onEsc = true
    }
}
