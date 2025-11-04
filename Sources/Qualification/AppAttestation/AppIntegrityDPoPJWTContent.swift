import Foundation.NSDate
import TokenGeneration

struct AppIntegrityDPoPJWTContent: JWTContent {
    let jwk: [String: String]

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
            "iat": Int(Date.now.timeIntervalSince1970) + 180,
            "jti": UUID().uuidString
        ]
    }
}
