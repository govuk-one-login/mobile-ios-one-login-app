@testable import AppIntegrity
import Foundation
import Testing

struct AppIntegrityServiceTests {
    @Test("""
          Check that the Attestation URL is well formed.
          """)
    func testAttestationRequestURL() throws {
        let request = URLRequest.assert(token: "test-token")

        #expect(request.url?.absoluteString ==
                "https://app-integrity-spike.mobile.dev.account.gov.uk/client-attestation?device=ios")
    }

    @Test("""
          Check that the JWKs data is sent
          """)
    func testAttestationRequestBody() throws {
        let token = UUID().uuidString

        let request = URLRequest.assert(token: token)
        let data = """
        {
            "jwk": "\(token)"
        }
        """

        #expect(request.httpBody == data.data(using: .utf8))
    }
}
