import Foundation.NSDate

enum AppIntegrityDPoPJWT {
    case headers(jwk: [String: String]), payload
    
    func callAsFunction() -> [String: Any] {
        switch self {
        case .headers(let jwk):
            [
                "alg": "ES256",
                "typ": "dpop+jwt",
                "jwk": jwk
            ]
        case .payload:
            [
                "htm": "POST",
                "htu": AppEnvironment.stsToken.absoluteString,
                "iat": Int(Date.now.timeIntervalSince1970) + 180,
                "jti": UUID().uuidString
            ]
        }
    }
}
