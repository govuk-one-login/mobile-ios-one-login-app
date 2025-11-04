import Foundation.NSDate
import TokenGeneration

struct AppIntegrityDPoPJWT: JWTContent {
    private let jwk: [String: String]
    
    var header: [String: Any] {
        [
            "alg": "ES256",
            "typ": "dpop+jwt",
            "jwk": jwk
        ]
    }
    
    var payload: [String: Any] {
        [
            "htm": "POST",
            "htu": AppEnvironment.stsToken.absoluteString,
            "iat": Int(Date.now.timeIntervalSince1970),
            "jti": UUID().uuidString
        ]
    }
    
    init(jwk: [String : String]) {
        self.jwk = jwk
    }
}
