import SwiftUI

protocol CPViewModelBindable: AnyObject {
    func bind()
    func unbind()
}

protocol CPViewModelAvailability: AnyObject {
    var enabled: Bool { get set }
    var disableSecondary: Bool { get set }
    var disableTitle: Bool { get set }
    var disableIcon: Bool { get set }
}

protocol CPButtonViewModel: ObservableObject, CPViewModelBindable {
    var primaryIcon: Image? { get set }
    var primaryTitle: String? { get set }
    var secondaryTitle: String? { get set }
    var tintColor: Color { get set }
}

extension CPViewModelBindable {
    func bind() {}
    func unbind() {}
}
