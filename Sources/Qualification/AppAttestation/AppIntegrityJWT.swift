import Foundation.NSDate

enum AppIntegrityJWT {
    case headers
    case payload
    
    func callAsFunction() -> [String: Any] {
        switch self {
        case .headers:
            [
                "alg": "ES256",
                "typ": "oauth-client-attestation-pop+jwt"
            ]
        case .payload:
            [
                "iss": AppEnvironment.stsClientID,
                "aud": AppEnvironment.stsBaseURL.absoluteString,
                "exp": Int(Date.now.timeIntervalSince1970) + 180,
                "jti": UUID().uuidString
            ]
        }
    }
}
