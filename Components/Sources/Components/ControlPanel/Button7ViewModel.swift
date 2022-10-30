import SwiftUI
import Features
import Programmator

class Button7ViewModel: ControlPanelButtonViewModel, PickListPopoverCallback {
    @Published var disableSecondary: Bool = false
    @Published var disableTitle: Bool = false
    @Published var disableIcon: Bool = false
    @Published var enabled: Bool = true
    @Published var primaryIcon: Image?
    @Published var primaryTitle: String?
    @Published var secondaryTitle: String?
    @Published var tintColor: Color = .green
    @Published var tag: CPViewModelTag? {
        didSet {
            enabled = tag != nil
        }
    }
    @Published var showVisionObjects: Bool = false
    var items: [VisionObject] = VisionObject.allCases

    private let assembler: AssemblerModel

    init(assembler: AssemblerModel) {
        self.assembler = assembler
        self.primaryIcon = .init(systemName: "arrow.down.backward.square")
        self.primaryTitle = "7"
        self.secondaryTitle = L10n.vision
    }
    
    func onClick() {
        if tag is Extension.ConditionValue {
            showVisionObjects = true
        }
    }
}

extension Button7ViewModel {
    func onItemSelected(item: VisionObject) {
        assembler.extend(with: item)
        showVisionObjects = false
    }
}
