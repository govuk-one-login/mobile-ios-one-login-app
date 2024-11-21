import Foundation

struct AppAttestJWTPayload {
    static var value: [String: Any] {
        ["iss": AppEnvironment.stsClientID,
         "aud": AppEnvironment.oneLoginBaseURL,
         "exp": Int(Date.now.timeIntervalSince1970 + 3),
         "jti": UUID().uuidString ]
    }
}
