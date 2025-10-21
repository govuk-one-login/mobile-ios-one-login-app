import Foundation
@testable import OneLogin
import Testing

struct AppIntegrityDPoPJWTTests {
    @Test("Initialise header from value")
    func initialiseJWTHeader() {
        let header = AppIntegrityDPoPJWT.headers(
            jwk: [
                "test_key_1": "test_value_1",
                "test_key_2": "test_value_2"
            ]
        )()
        
        #expect(header["alg"] as? String == "ES256")
        #expect(header["typ"] as? String == "dpop+jwt")
        #expect(header["jwk"] as? [String: String] == [
            "test_key_1": "test_value_1",
            "test_key_2": "test_value_2"
        ])
    }
    
    @Test("Initialise payload from value")
    func initialiseJWTPayload() {
        let payload = AppIntegrityDPoPJWT.payload()
        let expiryDate = Int(Date().timeIntervalSince1970) + 180
        
        #expect(payload["htm"] as? String == "POST")
        #expect(payload["htu"] as? String == AppEnvironment.stsToken.absoluteString)
        #expect(payload["iat"] as? Int == expiryDate)
        #expect((payload["jti"] as? String)?.count == 36)
    }
}
