import Authentication
import Networking

enum TokenError: Error {
    case bearerNotPresent
}

class TokenHolder: AuthenticationProvider {
    var tokenResponse: TokenResponse?
    var accessToken: String?
    
    var bearerToken: String {
        get throws {
            guard let accessToken else {
                throw TokenError.bearerNotPresent
            }
            return accessToken
        }
    }
    
    var validAccessToken: Bool {
        tokenResponse?.expiryDate.timeIntervalSinceNow.sign == .plus
    }
}
