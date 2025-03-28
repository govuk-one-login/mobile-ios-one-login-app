public enum LocalAuthType {
    case none
    case passcodeOnly
    case touchID
    case faceID
    /// `anyBiometrics` Will never be returned
    case anyBiometrics
    
    var tier: Int {
        get throws {
            switch self {
            case .none:
                0
            case .passcodeOnly:
                1
            case .anyBiometrics:
                2
            case .touchID, .faceID:
                throw LocalAuthTypeError.incorrectUse
            }
        }
    }
}

public enum LocalAuthTypeError: Error {
    case incorrectUse
    
    var localizedDescription: String {
        "Use `anyBiometrics` instead"
    }
}
