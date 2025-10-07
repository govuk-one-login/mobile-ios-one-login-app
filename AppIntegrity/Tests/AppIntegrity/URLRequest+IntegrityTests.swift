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
    func testAttestationRequestURL() {
        let request = URLRequest.clientAttestation(baseURL: baseURL, token: "test-token", body: Data())

        #expect(request.url?.absoluteString ==
                "https://token.build.account.gov.uk/client-attestation")
    }

    @Test("""
          Check that the Firebase Token is sent
          """)
    func testAttestationRequestHeaders() {
        let token = UUID().uuidString

        let request = URLRequest.clientAttestation(baseURL: baseURL, token: token, body: Data())
        #expect(request.allHTTPHeaderFields == [
            "Content-Type": "application/json",
            "X-Firebase-AppCheck": token
        ])
    }

    @Test("""
          Check that the JWKs data is sent
          """)
    func testAttestationRequestBody() throws {
        let data = Data("""
        {
          "jwk": {
            "kty": EC",
            "use": "sig",
            "crv": "P-256",
            "x": "18wHLeIgW9wVN6VD1Txgpqy2LszYkMf6J8njVAibvhM",
            "y": "-V4dS4UaLMgP_4fY4j8ir7cl1TXlFdAgcx55o7TkcSA"
          }
        }
        """.utf8)


        let request = URLRequest.clientAttestation(
            baseURL: baseURL,
            token: UUID().uuidString,
            body: data
        )
        let requestData = try #require(request.httpBody)

        #expect(requestData == data)
    }
}
