public enum RequiredLocalAuthLevel {
    case none
    case passcodeOnly
    case anyBiometrics
    
    var tier: Int {
        switch self {
        case .none:
            0
        case .passcodeOnly:
            1
        case .anyBiometrics:
            2
        }
    }
}
