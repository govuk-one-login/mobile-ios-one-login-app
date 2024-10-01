@testable import AppIntegrity
import FirebaseAppCheck
import Foundation
import MockNetworking
@testable import Networking
import Testing

@Suite(.serialized)
struct FirebaseAppIntegrityServiceTests {
    let sut: FirebaseAppIntegrityService

    init() throws {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [
            MockURLProtocol.self
        ]

        let client = NetworkClient(configuration: configuration)
        let baseURL = try #require(URL(string: "https://token.build.account.gov.uk"))

        sut = FirebaseAppIntegrityService(
            vendorType: MockAppCheckVendor.self,
            providerFactory: AppCheckDebugProviderFactory(),
            client: client,
            baseURL: baseURL
        )
    }

    @Test("""
          Check that 401 throws invalid token error
          """)
    func testAssertIntegrity401() async throws {
        MockURLProtocol.handler = {
            (Data(), HTTPURLResponse(statusCode: 401))
        }

        await #expect(throws: AppIntegrityError.invalidToken) {
            try await sut.assertIntegrity()
        }
    }

    @Test("""
          Check that 400 throws invalid public key error
          """)
    func testAssertIntegrity400() async throws {
        MockURLProtocol.handler = {
            (Data(), HTTPURLResponse(statusCode: 400))
        }

        await #expect(throws: AppIntegrityError.invalidPublicKey) {
            try await sut.assertIntegrity()
        }
    }

    @Test("""
          Check that 200 returns the client attestation
          """)
    func testAssertIntegritySuccess() async throws {
        MockURLProtocol.handler = {
            (Data(), HTTPURLResponse(statusCode: 200))
        }

        try await sut.assertIntegrity()
    }

    @Test("""
          Check that headers are added to URL
          """)
    func testAddIntegrityAssertions() async throws {
        let baseURL = try #require(URL(string: "https://token.build.account.gov.uk"))
        let request = URLRequest(url: baseURL)

        let assertedRequest = sut.addIntegrityAssertions(to: request)
        #expect(assertedRequest.allHTTPHeaderFields == [
            "OAuth-Client-Attestation": "abc",
            "OAuth-Client-Attestation-PoP": "def"
        ])
    }
}
