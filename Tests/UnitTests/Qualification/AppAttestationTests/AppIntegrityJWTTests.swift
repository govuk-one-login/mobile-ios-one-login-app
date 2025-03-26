import Foundation
@testable import OneLogin
import Testing

 struct AppIntegrityJWTTests {

    @Test("""
          Initialise header from value
          """)
    func initialiseJWTHeader() {
        let header = AppIntegrityJWT.headers()

        #expect(header as? [String: String] == ["alg": "ES256",
                                                "typ": "oauth-client-attestation-pop+jwt"])
    }
     
     @Test("""
           Initialise payload from value
           """)
     func initialiseJWTPayload() {
         let payload = AppIntegrityJWT.payload()
         let expiryDate = Int(Date().timeIntervalSince1970) + 180

         #expect(payload["iss"] as? String == AppEnvironment.stsClientID)
         #expect(payload["aud"] as? String == AppEnvironment.stsBaseURL.absoluteString)
         #expect(payload["exp"] as? Int == expiryDate)
         #expect((payload["jti"] as? String)?.count == 36)
     }
 }
