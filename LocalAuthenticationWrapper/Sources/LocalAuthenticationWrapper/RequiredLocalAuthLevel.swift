public enum RequiredLocalAuthLevel {
    case none
    case passcodeOnly
    case anyBiometricsAndPasscode
    
    var tier: Int {
        switch self {
        case .none:
            LocalAuthTier.none.rawValue
        case .passcodeOnly:
            LocalAuthTier.passcodeOnly.rawValue
        case .anyBiometricsAndPasscode:
            LocalAuthTier.anyBiometricsAndPasscode.rawValue
        }
    }
}

enum LocalAuthTier: Int {
    case none
    case passcodeOnly
    case anyBiometricsAndPasscode
}
