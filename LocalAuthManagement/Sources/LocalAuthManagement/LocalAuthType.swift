public protocol LocalAuthType: Equatable {
    static var none: Self { get }
    static var passcodeOnly: Self { get }
    static var touchID: Self { get }
    static var faceID: Self { get }
}

extension LocalAuthType {
    var rawValue: Int {
        switch self {
        case .none: return 0
        case .passcodeOnly: return 1
        case .touchID: return 2
        case .faceID: return 3
        default: fatalError("Unexpected case")
        }
    }
}

enum MyLocalAuthType: LocalAuthType {
    case none
    case passcodeOnly
    case touchID
    case faceID
}
