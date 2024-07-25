import Authentication
import Networking

enum TokenError: Error {
    case bearerNotPresent
    case launchExpired
    case useExpired
}

class TokenHolder: AuthenticationProvider {
    static let shared = TokenHolder()
    
    private init() { /* Empty private initialiser to ensure singleton */ }
    
    var tokenResponse: TokenResponse? {
        didSet {
            accessToken = tokenResponse?.accessToken
        }
    }
    
    var accessToken: String?
    var validAccessToken: Bool {
        tokenResponse?.expiryDate.timeIntervalSinceNow.sign == .plus
    }
    
    var bearerToken: String {
        get throws {
            guard let accessToken else {
                throw TokenError.bearerNotPresent
            }
            return accessToken
        }
    }
    
    var idTokenPayload: IdTokenPayload?
    
    func clearTokenHolder() {
        tokenResponse = nil
        accessToken = nil
        idTokenPayload = nil
    }
}
