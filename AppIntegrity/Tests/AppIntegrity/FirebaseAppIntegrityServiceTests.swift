// swiftlint:disable file_length
@testable import AppIntegrity
import FirebaseAppCheck
import FirebaseCore
import Foundation
import MockNetworking
@testable import Networking
import Testing

// swiftlint:disable type_body_length
@Suite(.serialized)
struct FirebaseAppIntegrityServiceTests {
    let mockVendor: MockAppCheckVendor
    let networkClient: NetworkClient
    let mockProofOfPossessionProvider: MockProofOfPossessionProvider
    let baseURL: URL
    let mockProofTokenGenerator: MockProofTokenGenerator
    let mockAttestationStore: MockAttestationStore
    let sut: FirebaseAppIntegrityService
    
    init() throws {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [
            MockURLProtocol.self
        ]
        
        MockURLProtocol.clear()
        
        mockVendor = MockAppCheckVendor()
        networkClient = NetworkClient(configuration: configuration)
        mockProofOfPossessionProvider = MockProofOfPossessionProvider()
        baseURL = try #require(URL(string: "https://mobile.build.account.gov.uk"))
        mockProofTokenGenerator = MockProofTokenGenerator()
        mockAttestationStore = MockAttestationStore()
        
        sut = FirebaseAppIntegrityService(
            vendor: mockVendor,
            networkClient: networkClient,
            proofOfPossessionProvider: mockProofOfPossessionProvider,
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
          AppCheck vendor throws unknown error from limitedUseToken
          """)
    func testAppCheckUnknownError() async throws {
        mockVendor.errorFromLimitedUseToken = NSError(domain: AppCheckErrorDomain, code: 0)
        
        await #expect(
            throws: AppIntegrityError<FirebaseAppCheckError>(
                .unknown,
                errorDescription: "The operation couldn’t be completed. (com.firebase.appCheck error 0.)"
            )
        ) {
            try await sut.integrityAssertions
        }
    }
    
    @Test("""
          AppCheck vendor throws network error from limitedUseToken
          """)
    func testAppCheckNetworkError() async throws {
        mockVendor.errorFromLimitedUseToken = NSError(domain: AppCheckErrorDomain, code: 1)
        
        await #expect(
            throws: AppIntegrityError<FirebaseAppCheckError>(
                .network,
                errorDescription: "The operation couldn’t be completed. (com.firebase.appCheck error 1.)"
            )
        ) {
            try await sut.integrityAssertions
        }
    }
    
    @Test("""
          AppCheck vendor throws invalid configuration error from limitedUseToken
          """)
    func testAppCheckInvalidconfigurationError() async throws {
        mockVendor.errorFromLimitedUseToken = NSError(domain: AppCheckErrorDomain, code: 2)
        
        await #expect(
            throws: AppIntegrityError<FirebaseAppCheckError>(
                .invalidConfiguration,
                errorDescription: "The operation couldn’t be completed. (com.firebase.appCheck error 2.)"
            )
        ) {
            try await sut.integrityAssertions
        }
    }
    
    @Test("""
          AppCheck vendor throws keychain access error from limitedUseToken
          """)
    func testAppCheckKeychainAccessError() async throws {
        mockVendor.errorFromLimitedUseToken = NSError(domain: AppCheckErrorDomain, code: 3)
        
        await #expect(
            throws: AppIntegrityError<FirebaseAppCheckError>(
                .keychainAccess,
                errorDescription: "The operation couldn’t be completed. (com.firebase.appCheck error 3.)"
            )
        ) {
            try await sut.integrityAssertions
        }
    }
    
    @Test("""
          AppCheck vendor throws not supported error from limitedUseToken
          """)
    func testAppCheckNotSupportedError() async throws {
        mockVendor.errorFromLimitedUseToken = NSError(domain: AppCheckErrorDomain, code: 4)
        
        await #expect(
            throws: AppIntegrityError<FirebaseAppCheckError>(
                .notSupported,
                errorDescription: "The operation couldn’t be completed. (com.firebase.appCheck error 4.)"
            )
        ) {
            try await sut.integrityAssertions
        }
    }
    
    @Test("""
          AppCheck vendor throws generic error from limitedUseToken
          """)
    func testAppCheckGenericError() async throws {
        mockVendor.errorFromLimitedUseToken = NSError(domain: AppCheckErrorDomain, code: 5)
        
        await #expect(
            throws: AppIntegrityError<FirebaseAppCheckError>(
                .generic,
                errorDescription: "The operation couldn’t be completed. (com.firebase.appCheck error 5.)"
            )
        ) {
            try await sut.integrityAssertions
        }
    }
    
    @Test("""
          Check that 400 throws invalid public key error
          """)
    func testAssertIntegrity400() async throws {
        MockURLProtocol.handler = {
            (Data(), HTTPURLResponse(statusCode: 400))
        }
        
        await #expect(
            throws: AppIntegrityError<ClientAssertionError>(
                .serverError,
                underlyingReason: "The operation couldn’t be completed. (Networking.ServerError error 500.)"
            )
        ) {
            try await sut.integrityAssertions
        }
    }
    
    @Test("""
          Check that 401 throws invalid token error
          """)
    func testAssertIntegrity401() async throws {
        MockURLProtocol.handler = {
            (Data(), HTTPURLResponse(statusCode: 401))
        }

        await #expect(
            throws: AppIntegrityError<ClientAssertionError>(
                .invalidToken,
                underlyingReason: "The operation couldn’t be completed. (Networking.ServerError error 401.)"
            )
        ) {
            try await sut.integrityAssertions
        }
    }
    
    @Test("""
          Check that 500 throws txma server error
          """)
    func testAssertIntegrity500() async throws {
        MockURLProtocol.handler = {
            (Data(), HTTPURLResponse(statusCode: 500))
        }

        await #expect(
            throws: AppIntegrityError<ClientAssertionError>(
                .serverError,
                errorDescription: "The operation couldn’t be completed. (Networking.ServerError error 1.)"
            )
        ) {
            try await sut.integrityAssertions
        }
    }
    
    @Test("""
          Proof token generator returns error cant create attestation PoP error
          """)
    func testAttestationPoPError() async throws {
        mockProofTokenGenerator.header = ["mockHeaderKey1": "mockHeaderValue1"]
        mockProofTokenGenerator.payload = ["mockPayloadKey1": "mockPayloadValue1"]
        
        MockURLProtocol.handler = {
            (Data("""
             {
              "client_attestation": "testAttestation",
              "expires_in": 86400
             }
            """.utf8), HTTPURLResponse(statusCode: 200))
        }
        
        mockProofTokenGenerator.errorFromToken = NSError(domain: "test domain", code: 0)
        
        await #expect(
            throws: AppIntegrityError<ClientAssertionError>(
                .invalidPublicKey,
                underlyingReason: "The operation couldn’t be completed. (Networking.ServerError error 400.)"
            )
        ) {
            try await sut.integrityAssertions
        }
    }
    
    @Test("""
          Check the saved attestation and proof token are returned if valid
          """)
    func testSavedIntegrityAssertion() async throws {
        mockProofTokenGenerator.header = ["mockHeaderKey1": "mockHeaderValue1"]
        mockProofTokenGenerator.payload = ["mockPayloadKey1": "mockPayloadValue1"]
        
        mockAttestationStore.validAttestation = true
        
        let integrityResponse = try await sut.integrityAssertions
        
        #expect(integrityResponse["OAuth-Client-Attestation"] == "testSavedAttestation")
        let header = try #require(
            integrityResponse["OAuth-Client-Attestation-PoP"]?
                .contains(#""mockHeaderKey1": "mockHeaderValue1""#) as Bool?
        )
        #expect(header)
        
        let payload = try #require(
            integrityResponse["OAuth-Client-Attestation-PoP"]?
                .contains(#""mockPayloadKey1": "mockPayloadValue1""#) as Bool?
        )
        #expect(payload)
    }
    
    @Test("""
          Check that 200 returns the client attestation
          """)
    func testAssertIntegritySuccess() async throws {
        MockURLProtocol.handler = {
            (Data("""
             {
              "client_attestation": "testAttestation",
              "expires_in": 86400
             }
            """.utf8), HTTPURLResponse(statusCode: 200))
        }
        
        _ = try await sut.integrityAssertions
        
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
        mockProofTokenGenerator.header = ["mockHeaderKey1": "mockHeaderValue1"]
        mockProofTokenGenerator.payload = ["mockPayloadKey1": "mockPayloadValue1"]
        
        MockURLProtocol.handler = {
            (Data("""
             {
              "client_attestation": "testAttestation",
              "expires_in": 86400
             }
            """.utf8), HTTPURLResponse(statusCode: 200))
        }
        
        let integrityResponse = try await sut.integrityAssertions
        
        #expect(integrityResponse["OAuth-Client-Attestation"] == "testAttestation")
        let header = try #require(
            integrityResponse["OAuth-Client-Attestation-PoP"]?
                .contains(#""mockHeaderKey1": "mockHeaderValue1""#) as Bool?
        )
        #expect(header)
        
        let payload = try #require(
            integrityResponse["OAuth-Client-Attestation-PoP"]?
                .contains(#""mockPayloadKey1": "mockPayloadValue1""#) as Bool?
        )
        #expect(payload)
        
        #expect(
            mockAttestationStore.mockStorage["attestationJWT"] as? String == "testAttestation"
        )
        if #available(iOS 15.0, *) {
            #expect(
                (mockAttestationStore.mockStorage["attestationExpiry"] as? Date)?
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
              "client_attestation": "testAttestation",
              "expires_in": \(expiresIn)
             }
            """.utf8), HTTPURLResponse(statusCode: 200))
        }
        
        let initialDate = Date()
        let response = try await sut
            .fetchClientAttestation(appCheckToken: UUID().uuidString)
        #expect(response.attestationJWT == "testAttestation")
        
        // Expiry time should be more a day since before we made the request
        // but less than a day from now
        #expect(response.expiryDate > initialDate.addingTimeInterval(expiresIn))
        #expect(response.expiryDate < Date().addingTimeInterval(expiresIn))
    }
    
    @Test("""
          Check that client attestation request returns a server error
          """)
    func testFetchClientAttestationServerError() async throws {
        MockURLProtocol.handler = {
            (Data(), HTTPURLResponse(statusCode: 400))
        }
        
        await #expect(
            throws: ServerError(endpoint: "client-attestation", errorCode: 400)
        ) {
            try await sut
                .fetchClientAttestation(appCheckToken: UUID().uuidString)
        }
    }
    
    @Test("""
          Check that client attestation request payload results in a decoding error
          """)
    func testFetchClientAttestationDecodingError() async throws {
        MockURLProtocol.handler = {
            (Data("""
             {
              "client_attestation": "testAttestation",
              "expires_in":
             }
            """.utf8), HTTPURLResponse(statusCode: 200))
        }
        
        await #expect(
            throws: AppIntegrityError<ClientAssertionError>(
                .cantDecodeClientAssertion,
                errorDescription: "test description"
            )
        ) {
            try await sut
                .fetchClientAttestation(appCheckToken: UUID().uuidString)
        }
    }
    
    @Test("""
          Check that client attestation request public key error is caught
          """)
    func testFetchClientAttestationPublicKey() async throws {
        mockProofOfPossessionProvider.errorFromPublicKey = NSError(domain: "test domain", code: 0)
        
        await #expect(
            throws: AppIntegrityError<ProofOfPossessionError>(
                .cantGeneratePublicKey,
                errorDescription: "test desciption"
            )
        ) {
            try await sut
                .fetchClientAttestation(appCheckToken: UUID().uuidString)
        }
    }
}
// swiftlint:enable type_body_length

extension ServerError: @retroactive Equatable {
    public static func == (lhs: ServerError, rhs: ServerError) -> Bool {
        lhs.endpoint == rhs.endpoint && lhs.errorCode == rhs.errorCode
    }
}
