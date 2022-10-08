import Programmator

protocol CPViewModelTag {}

protocol CPViewModelClickable<Tag> {
    associatedtype Tag
    var tag: Tag? { get set }

    func onClick()
}

extension CPViewModelClickable {
    func onClick() {}
}
