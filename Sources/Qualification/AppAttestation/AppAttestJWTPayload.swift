import Foundation

struct AppAttestJWTPayload {
    let issuer: String
    let audience: String
    let expiryDate: Int
    let jwtID: String

    init(issuer: String, audience: String, expiryDate: Date = Date(), jwtID: String) {
        self.issuer = issuer
        self.audience = audience
        self.expiryDate = Int(expiryDate.timeIntervalSince1970 + 3)
        self.jwtID = jwtID
    }

    var value: [String: Any] {
        ["iss": issuer,
         "aud": audience,
         "exp": expiryDate,
         "jti": jwtID ]
    }
}
