import SwiftUI

extension ControlPanelButtonView {
    class ViewModel: ObservableObject {
        @Published var enabled: Bool = true
        @Published var primaryIcon: Image?
        @Published var primaryTitle: String?
        @Published var secondaryTitle: String?
        @Published var tintColor: Color = .green

        func bind() {
        }

        func unbind() {
        }

        func onClick() {
        }
    }
}
