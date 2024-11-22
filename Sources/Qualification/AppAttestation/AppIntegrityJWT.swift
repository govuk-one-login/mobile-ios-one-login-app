import Foundation.NSDate

enum AppIntegrityJWT {
    case headers
    case payload
    
    func callAsFunction() -> [String: Any] {
        switch self {
        case .headers:
            ["alg": "ES256"]
        case .payload:
            [
                "iss": AppEnvironment.stsClientID,
                "aud": AppEnvironment.stsBaseURL.absoluteString,
                "exp": Int((Date.now + 180).timeIntervalSince1970),
                "jti": UUID().uuidString
            ]
        }
    }
}
