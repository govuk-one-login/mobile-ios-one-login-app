public enum LocalAuthType: Equatable {
    case none
    case passcodeOnly
    case biometry(type: BiometryType)
    
    public enum BiometryType {
        case touchID
        case faceID
    }
    
    var rawValue: Int {
        switch self {
        case .none:
            0
        case .passcodeOnly:
            1
        case .biometry:
            2
        }
    }
}
