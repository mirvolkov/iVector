protocol CPViewModelTag {
    var id: AnyObject { get set }
}

protocol CPViewModelClickable<Tag> {
    associatedtype Tag
    var tag: Tag? { get set }

    func onClick()
}

extension CPViewModelClickable {
    func onClick() {}
    
    var tag: CPViewModelTag? { nil }
}
