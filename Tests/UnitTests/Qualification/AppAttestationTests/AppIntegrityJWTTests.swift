import Foundation
@testable import OneLogin
import Testing

 struct AppIntegrityJWTTests {

    @Test("""
          Initialise header from value
          """)
    func initialiseJWTHeader() {
        let header = AppIntegrityJWT.headers()

        #expect(header as? [String: String] == ["alg": "ES256"])
    }
     
     @Test("""
           Initialise payload from value
           """)
     func initialiseJWTPayload() {
         let payload = AppIntegrityJWT.payload()
//         let expiryDate: Int

         #expect(payload["iss"] as? String == "bYrcuRVvnylvEgYSSbBjwXzHrwJ")
         #expect(payload["aud"] as? String == "https://token.build.account.gov.uk")
//         #expect(payload["exp"] as? Int =
         #expect((payload["jti"] as? String)?.count == 36)
     }
 }
