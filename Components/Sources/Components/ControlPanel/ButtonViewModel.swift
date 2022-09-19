import SwiftUI

protocol CPViewModelBindable {
    func bind()
    func unbind()
}


protocol CPButtonViewModel: ObservableObject, CPViewModelBindable {
    var enabled: Bool { get set }
    var primaryIcon: Image? { get set }
    var primaryTitle: String? { get set }
    var secondaryTitle: String? { get set }
    var tintColor: Color { get set }
}

extension CPViewModelBindable {
    func bind() {}
    func unbind() {}
}
