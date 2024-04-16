import Authentication
import Networking

class TokenHolder: AuthenticationProvider {
    var tokenResponse: TokenResponse?
    var accessToken: String?
    
    var bearerToken: String {
        accessToken ?? ""
    }
    
    var validAccessToken: Bool {
        tokenResponse?.expiryDate.timeIntervalSinceNow.sign == .plus
    }
}
