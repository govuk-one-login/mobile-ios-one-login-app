@testable import AppIntegrity
import FirebaseAppCheck
import Foundation
import MockNetworking
@testable import Networking
import Testing

struct FirebaseAppIntegrityServiceTests {
    let sut: FirebaseAppIntegrityService

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [
            MockURLProtocol.self
        ]

        let client = NetworkClient(configuration: configuration)

        sut = FirebaseAppIntegrityService(
            vendorType: MockAppCheckVendor.self,
            providerFactory: AppCheckDebugProviderFactory(),
            client: client)
    }

    @Test("""
          Check that 401 throws invalid token error
          """)
    func testAssertIntegrity401() async throws {
        // TODO: return 401 from mock token endpoint

        Task {
            do {
                try await sut.assertIntegrity()
            } catch AppIntegrityError.invalidToken {
                return
            }
        }

        // TODO: await response
        #expect(Bool(false))
    }

    @Test("""
          Check that 400 throws invalid public key error
          """)
    func testAssertIntegrity400() async throws {
        #expect(Bool(false))
    }

    @Test("""
          Check that 200 returns the client attestation
          """)
    func testAssertIntegritySuccess() async throws {
        #expect(Bool(false))
    }
}
