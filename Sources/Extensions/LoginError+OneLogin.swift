import Authentication

extension LoginError {
    var localizedDescription: String {
        switch self {
        case .clientError:
            return "client error"
        case .generic(description: let description):
            return description
        case .invalidRequest:
            return "invalid request"
        case .network:
            return "network"
        case .non200:
            return "non 200"
        case .userCancelled:
            return "user cancelled"
        }
    }
}
