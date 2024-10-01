@testable import AppIntegrity
import Foundation
import Testing

struct AppIntegrityServiceTests {
    let baseURL: URL

    init() throws {
        baseURL = try #require(URL(string: "https://token.build.account.gov.uk"))
    }

    @Test("""
          Check that the Attestation URL is well formed.
          """)
    func testAttestationRequestURL() throws {
        let request = try URLRequest.clientAttestation(baseURL: baseURL, token: "test-token")

        #expect(request.url?.absoluteString ==
                "https://token.build.account.gov.uk/client-attestation")
    }

    @Test("""
          Check that the Firebase Token is sent
          """)
    func testAttestationRequestHeaders() throws {
        let token = UUID().uuidString

        let request = try URLRequest.clientAttestation(baseURL: baseURL, token: token)
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

        let request = try URLRequest.clientAttestation(baseURL: baseURL, token: token)
        let responseData = try #require(request.httpBody)
        let response = try #require(String(data: responseData, encoding: .utf8))

        #expect(response == """
        {"jwk":"\(token)"}
        """)
    }
}
