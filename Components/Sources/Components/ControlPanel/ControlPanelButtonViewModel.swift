import Combine
import SwiftUI

class ControlPanelButtonViewModelBasic: ControlPanelButtonViewModel {
    @Published var disableSecondary: Bool = false
    @Published var disableTitle: Bool = false
    @Published var disableIcon: Bool = false
    @Published var enabled: Bool = true
    @Published var primaryIcon: Image?
    @Published var primaryTitle: String?
    @Published var secondaryTitle: String?
    @Published var tintColor: Color = .green
    @Published var tag: (any CPViewModelTag)?
    
    init(_ icon: Image, title: String? = nil, subtitle: String? = nil) {
        self.primaryIcon = icon
        self.primaryTitle = title
        self.secondaryTitle = subtitle
    }
}
