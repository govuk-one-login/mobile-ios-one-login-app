import Foundation.NSDate
import TokenGeneration

struct AppIntegrityPoPJWTContent: JWTContent {
    var header: [String: Any] {
        [
            "alg": "ES256",
            "typ": "oauth-client-attestation-pop+jwt"
        ]
    }

    var payload: [String: Any] {
        [
            "iss": AppEnvironment.stsClientID,
            "aud": AppEnvironment.stsBaseURL.absoluteString,
            "exp": Int(Date.now.timeIntervalSince1970) + 180,
            "jti": UUID().uuidString
        ]
    }
}
