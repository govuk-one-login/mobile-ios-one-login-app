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
                "aud": "www." + AppEnvironment.stsToken.absoluteString,
                "exp": Int(Date.now.timeIntervalSince1970) + 180,
                "jti": UUID().uuidString
            ]
        }
    }
}
