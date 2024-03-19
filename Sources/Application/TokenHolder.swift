import Authentication

class TokenHolder {
    var tokenResponse: TokenResponse?
    var accessToken: String?
    
    var validAccessToken: Bool {
        tokenResponse?.expiryDate.timeIntervalSinceNow.sign == .plus
    }
}
