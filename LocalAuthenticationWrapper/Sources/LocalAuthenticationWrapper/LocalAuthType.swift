public enum LocalAuthType: Equatable {
    case none
    case passcodeOnly
    case touchID
    case faceID
    case anyBiometrics
    
    var tier: Int {
        switch self {
        case .none:
            0
        case .passcodeOnly:
            1
        case .touchID, .faceID, .anyBiometrics:
            2
        }
    }
}
