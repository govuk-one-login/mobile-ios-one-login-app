@testable import AppIntegrity
import FirebaseAppCheck
import FirebaseCore
import Foundation
import MockNetworking
@testable import Networking
import Testing

@Suite(.serialized)
struct FirebaseAppIntegrityServiceTests {
    let sut: FirebaseAppIntegrityService
    let proofProvider: ProofOfPossessionProvider
    let networkClient: NetworkClient
    let baseURL: URL
    let mockProofTokenGenerator: MockProofTokenGenerator
    let mockAttestationStore: MockAttestationStore
    
    init() throws {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [
            MockURLProtocol.self
        ]

        MockURLProtocol.clear()

        proofProvider = MockProofOfPossessionProvider()

        networkClient = NetworkClient(configuration: configuration)
        baseURL = try #require(URL(string: "https://mobile.build.account.gov.uk"))
        mockProofTokenGenerator = MockProofTokenGenerator(header: ["mockHeaderKey1": "mockHeaderValue1"],
                                                          payload: ["mockPayloadKey1": "mockPayloadValue1"])
        mockAttestationStore = MockAttestationStore(attestationJWT: "test")

        sut = FirebaseAppIntegrityService(
            vendor: MockAppCheckVendor(),
            networkClient: networkClient,
            proofOfPossessionProvider: proofProvider,
            baseURL: baseURL,
            proofTokenGenerator: mockProofTokenGenerator,
            attestationStore: mockAttestationStore
        )
    }

    @Test("""
          AppCheck provider is correctly configured in debug mode
          """)
    func testConfigureAppCheckProvider() {
        FirebaseAppIntegrityService.configure(vendorType: MockAppCheckVendor.self)
        #expect(MockAppCheckVendor.wasConfigured is AppCheckDebugProviderFactory)
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
            (Data("""
             {
              "client_attestation": "eyJ...",
              "expires_in": 86400
             }
            """.utf8), HTTPURLResponse(statusCode: 200))
        }

        _ = try await sut.assertIntegrity()

        #expect(MockURLProtocol.requests.count == 1)
        #expect(
            MockURLProtocol.requests[0].url?.absoluteString ==
            "https://mobile.build.account.gov.uk/client-attestation"
        )
    }
    
    @Test("""
          Check that the assertIntegrity returns correct dictionary
          """)
    func testAssertIntegrityResponse() async throws {
        MockURLProtocol.handler = {
            (Data("""
             {
              "client_attestation": "eyJ...",
              "expires_in": 86400
             }
            """.utf8), HTTPURLResponse(statusCode: 200))
        }

        let integrityResponse = try await sut.assertIntegrity()
        
        #expect(integrityResponse["OAuth-Client-Attestation"] == "eyJ...")
        let header = try #require(
            integrityResponse["OAuth-Client-Attestation-PoP"]?
                .contains("\"mockHeaderKey1\": \"mockHeaderValue1\"") as Bool?
        )
        #expect(header)
        
        let payload = try #require(
            integrityResponse["OAuth-Client-Attestation-PoP"]?
                .contains("\"mockPayloadKey1\": \"mockPayloadValue1\"") as Bool?
        )
        #expect(payload)
        
        #expect(
            mockAttestationStore.mockStorage[AttestationStorageKey.attestationJWT.rawValue] as? String == "eyJ..."
        )
        if #available(iOS 15.0, *) {
            #expect(
                (mockAttestationStore.mockStorage[AttestationStorageKey.attestationExpiry.rawValue] as? Date)?
                    .formatted(.dateTime) == Date(timeIntervalSinceNow: 86400).formatted(.dateTime)
            )
        }
    }

    @Test("""
          Check that client attestation is decoded successfully
          """)
    func testFetchClientAttestation() async throws {
        let expiresIn: TimeInterval = 86400

        MockURLProtocol.handler = {
            (Data("""
             {
              "client_attestation": "eyJ...",
              "expires_in": \(expiresIn)
             }
            """.utf8), HTTPURLResponse(statusCode: 200))
        }

        let initialDate = Date()
        let response = try await sut
            .fetchClientAttestation(appCheckToken: UUID().uuidString)
        #expect(response.attestationJWT == "eyJ...")

        // Expiry time should be more a day since before we made the request
        // but less than a day from now
        #expect(response.expiryDate > initialDate.addingTimeInterval(expiresIn))
        #expect(response.expiryDate < Date().addingTimeInterval(expiresIn))
    }
 }
