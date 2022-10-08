import Combine
import Features
import SwiftUI
import Programmator

class ButtonEnterViewModel: ControlPanelButtonViewModel {
    @Published var disableSecondary: Bool = false
    @Published var disableTitle: Bool = false
    @Published var disableIcon: Bool = false
    @Published var enabled: Bool = true
    @Published var primaryIcon: Image?
    @Published var primaryTitle: String?
    @Published var secondaryTitle: String?
    @Published var tintColor: Color = .green
    @Published var onEnter: Bool = false
    @Published var tag: CPViewModelTag?

    private let assembler: AssemblerModel
    private var bag = Set<AnyCancellable>()

    init(assembler: AssemblerModel) {
        self.primaryIcon = .init(systemName: "pip.enter")
        self.primaryTitle = "Ent"
        self.assembler = assembler
    }

    func bind() {
        assembler.$current
            .map { $0?.isValid }
            .replaceNil(with: false)
            .assign(to: \.enabled, on: self)
            .store(in: &bag)
    }

    func onClick() {
        onEnter = true
    }
}
