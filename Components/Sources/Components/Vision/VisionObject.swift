import Features

extension VisionObject: CustomStringConvertible {
    public var description: String {
        switch self {
        case .apple:
            return L10n.apple
        case .cat:
            return L10n.cat
        case .cellPhone:
            return L10n.cellPhone
        case .clock:
            return L10n.clock
        case .person:
            return L10n.person
        case .stopSign:
            return L10n.stopSign
        }
    }
}
