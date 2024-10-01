@testable import AppIntegrity
import Foundation
import Testing

struct AppIntegrityServiceTests {
    @Test("""
          Check that the Attestation URL is well formed.
          """)
    func testAttestationRequestURL() throws {
        let request = try URLRequest.clientAttestation(token: "test-token")

        #expect(request.url?.absoluteString ==
                "https://app-integrity-spike.mobile.dev.account.gov.uk/client-attestation?device=ios")
    }

    @Test("""
          Check that the Firebase Token is sent
          """)
    func testAttestationRequestHeaders() throws {
        let token = UUID().uuidString

        let request = try URLRequest.clientAttestation(token: token)
        #expect(
            request.value(forHTTPHeaderField: "X-Firebase-AppCheck") ==
            token
        )
    }

    @Test("""
          Check that the JWKs data is sent
          """)
    func testAttestationRequestBody() throws {
        let token = UUID().uuidString

        let request = try URLRequest.clientAttestation(token: token)
        let responseData = try #require(request.httpBody)
        let response = try #require(String(data: responseData, encoding: .utf8))

        #expect(response == """
        {"jwk":"\(token)"}
        """)
    }
}
