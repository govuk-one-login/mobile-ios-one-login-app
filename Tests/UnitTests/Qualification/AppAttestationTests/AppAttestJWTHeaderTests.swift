@testable import OneLogin
import Testing

 struct AppAttestJWTHeaderTests {

    @Test("""
          Initialise header from value
          """)
    func initialiseJWTHeader() {
        let header = AppAttestJWTHeader(alg: "xyz")

        #expect(header.value == ["alg": "xyz"])
    }
 }
