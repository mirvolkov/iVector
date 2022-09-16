
extension ControlPanelButtonView {
    class MicViewModel: ViewModel {
        override init() {
            super.init()
            self.primaryIcon = .init(systemName: "mic")
        }
    }
}
