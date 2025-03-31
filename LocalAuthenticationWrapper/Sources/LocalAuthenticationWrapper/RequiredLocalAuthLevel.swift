public enum RequiredLocalAuthLevel {
    case none
    case passcodeOnly
    case anyBiometricsOrPasscode
    
    var tier: Int {
        switch self {
        case .none:
            LocalAuthTier.none.rawValue
        case .passcodeOnly:
            LocalAuthTier.passcodeOnly.rawValue
        case .anyBiometricsOrPasscode:
            LocalAuthTier.anyBiometricsOrPasscode.rawValue
        }
    }
}

enum LocalAuthTier: Int {
    case none
    case passcodeOnly
    case anyBiometricsOrPasscode
}
