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
    let mockAttestationProofOfPossessionProvider: MockProofOfPossessionProvider
    let mockAttestationProofOfPossessionTokenGenerator: MockProofOfPossessionTokenGenerator
    let mockDemonstratingProofOfPossessionTokenGenerator: MockProofOfPossessionTokenGenerator
    let mockAttestationStore: MockAttestationStore
    let networkClient: NetworkClient
    let sut: FirebaseAppIntegrityService
    
    init() throws {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [
            MockURLProtocol.self
        ]
        
        MockURLProtocol.clear()
        
        mockVendor = MockAppCheckVendor()
        mockAttestationProofOfPossessionProvider = MockProofOfPossessionProvider()
        mockAttestationProofOfPossessionTokenGenerator = MockProofOfPossessionTokenGenerator()
        mockDemonstratingProofOfPossessionTokenGenerator = MockProofOfPossessionTokenGenerator()
        mockAttestationStore = MockAttestationStore()
        networkClient = NetworkClient(configuration: configuration)
        
        sut = FirebaseAppIntegrityService(
            vendor: mockVendor,
            attestationProofOfPossessionProvider: mockAttestationProofOfPossessionProvider,
            attestationProofOfPossessionTokenGenerator: mockAttestationProofOfPossessionTokenGenerator,
            demonstratingProofOfPossessionTokenGenerator: mockDemonstratingProofOfPossessionTokenGenerator,
            attestationStore: mockAttestationStore,
            networkClient: networkClient,
            baseURL: try #require(URL(string: "https://mobile.build.account.gov.uk"))
        )
    }
    
    @Test("AppCheck provider is correctly configured in debug mode")
    func testConfigureAppCheckProvider() {
        FirebaseAppIntegrityService.configure(vendorType: MockAppCheckVendor.self)
        #expect(MockAppCheckVendor.wasConfigured is AppCheckDebugProviderFactory)
    }
    
    @Test("Check the saved attestation and proof token are returned if valid")
    func testSavedIntegrityAssertion() async throws {
        mockAttestationProofOfPossessionTokenGenerator.header = ["mockPoPHeaderKey1": "mockPoPHeaderValue1"]
        mockAttestationProofOfPossessionTokenGenerator.payload = ["mockPoPPayloadKey1": "mockPoPPayloadValue1"]
        
        mockDemonstratingProofOfPossessionTokenGenerator.header = ["mockDPoPHeaderKey1": "mockDPoPHeaderValue1"]
        mockDemonstratingProofOfPossessionTokenGenerator.payload = ["mockDPoPPayloadKey1": "mockDPoPPayloadValue1"]
        
        mockAttestationStore.attestationExpired = true
        
        let integrityResponse = try await sut.integrityAssertions
        
        #expect(
            integrityResponse["OAuth-Client-Attestation"] == "testSavedAttestation"
        )
        
        #expect(
            integrityResponse["OAuth-Client-Attestation-PoP"]?
                .contains(#""mockPoPHeaderKey1": "mockPoPHeaderValue1""#) ?? false
        )
        
        #expect(
            integrityResponse["OAuth-Client-Attestation-PoP"]?
                .contains(#""mockPoPPayloadKey1": "mockPoPPayloadValue1""#) ?? false
        )
        
        #expect(
            integrityResponse["DPoP"]?
                .contains(#""mockDPoPHeaderKey1": "mockDPoPHeaderValue1""#) ?? false
        )
        
        #expect(
            integrityResponse["DPoP"]?
                .contains(#""mockDPoPPayloadKey1": "mockDPoPPayloadValue1""#) ?? false
        )
    }
    
    @Test("Check that the assertIntegrity returns correct dictionary")
    func testAssertIntegrityResponse() async throws {
        MockURLProtocol.handler = {
            (Data("""
             {
              "client_attestation": "testAttestation",
              "expires_in": 86400
             }
            """.utf8),
             HTTPURLResponse(statusCode: 200))
        }
        
        mockAttestationProofOfPossessionTokenGenerator.header = ["mockPoPHeaderKey1": "mockPoPHeaderValue1"]
        mockAttestationProofOfPossessionTokenGenerator.payload = ["mockPoPPayloadKey1": "mockPoPPayloadValue1"]
        
        mockDemonstratingProofOfPossessionTokenGenerator.header = ["mockDPoPHeaderKey1": "mockDPoPHeaderValue1"]
        mockDemonstratingProofOfPossessionTokenGenerator.payload = ["mockDPoPPayloadKey1": "mockDPoPPayloadValue1"]
        
        let integrityResponse = try await sut.integrityAssertions
        
        #expect(
            integrityResponse["OAuth-Client-Attestation"] == "testAttestation"
        )
        
        #expect(
            integrityResponse["OAuth-Client-Attestation-PoP"]?
                .contains(#""mockPoPHeaderKey1": "mockPoPHeaderValue1""#) ?? false
        )
        
        #expect(
            integrityResponse["OAuth-Client-Attestation-PoP"]?
                .contains(#""mockPoPPayloadKey1": "mockPoPPayloadValue1""#) ?? false
        )
        
        #expect(
            integrityResponse["DPoP"]?
                .contains(#""mockDPoPHeaderKey1": "mockDPoPHeaderValue1""#) ?? false
        )
        
        #expect(
            integrityResponse["DPoP"]?
                .contains(#""mockDPoPPayloadKey1": "mockDPoPPayloadValue1""#) ?? false
        )
        
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
    
    @Test("AppCheck vendor throws unknown error from limitedUseToken")
    func testAppCheckUnknownError() async throws {
        mockVendor.errorFromLimitedUseToken = NSError(domain: AppCheckErrorDomain, code: 0)
        
        await #expect(
            throws: FirebaseAppCheckError(
                .unknown,
                errorDescription: "The operation couldn’t be completed. (com.firebase.appCheck error 0.)"
            )
        ) {
            try await sut.integrityAssertions
        }
    }
    
    @Test("AppCheck vendor throws network error from limitedUseToken")
    func testAppCheckNetworkError() async throws {
        mockVendor.errorFromLimitedUseToken = NSError(domain: AppCheckErrorDomain, code: 1)
        
        await #expect(
            throws: FirebaseAppCheckError(
                .network,
                errorDescription: "The operation couldn’t be completed. (com.firebase.appCheck error 1.)"
            )
        ) {
            try await sut.integrityAssertions
        }
    }
    
    @Test("AppCheck vendor throws invalid configuration error from limitedUseToken")
    func testAppCheckInvalidconfigurationError() async throws {
        mockVendor.errorFromLimitedUseToken = NSError(domain: AppCheckErrorDomain, code: 2)
        
        await #expect(
            throws: FirebaseAppCheckError(
                .invalidConfiguration,
                errorDescription: "The operation couldn’t be completed. (com.firebase.appCheck error 2.)"
            )
        ) {
            try await sut.integrityAssertions
        }
    }
    
    @Test("AppCheck vendor throws keychain access error from limitedUseToken")
    func testAppCheckKeychainAccessError() async throws {
        mockVendor.errorFromLimitedUseToken = NSError(domain: AppCheckErrorDomain, code: 3)
        
        await #expect(
            throws: FirebaseAppCheckError(
                .keychainAccess,
                errorDescription: "The operation couldn’t be completed. (com.firebase.appCheck error 3.)"
            )
        ) {
            try await sut.integrityAssertions
        }
    }
    
    @Test("AppCheck vendor throws not supported error from limitedUseToken")
    func testAppCheckNotSupportedError() async throws {
        mockVendor.errorFromLimitedUseToken = NSError(domain: AppCheckErrorDomain, code: 4)
        
        await #expect(
            throws: FirebaseAppCheckError(
                .notSupported,
                errorDescription: "The operation couldn’t be completed. (com.firebase.appCheck error 4.)"
            )
        ) {
            try await sut.integrityAssertions
        }
    }
    
    @Test("AppCheck vendor throws generic error from limitedUseToken")
    func testAppCheckGenericError() async throws {
        mockVendor.errorFromLimitedUseToken = NSError(domain: AppCheckErrorDomain, code: 5)
        
        await #expect(
            throws: FirebaseAppCheckError(
                .generic,
                errorDescription: "The operation couldn’t be completed. (com.firebase.appCheck error 5.)"
            )
        ) {
            try await sut.integrityAssertions
        }
    }
    
    @Test("Check that 400 throws invalid public key error")
    func testAssertIntegrity400() async throws {
        MockURLProtocol.handler = {
            (Data(), HTTPURLResponse(statusCode: 400))
        }
        
        await #expect(
            throws: ClientAssertionError(
                .invalidPublicKey,
                errorDescription: "The operation couldn’t be completed. (Networking.ServerError error 400.)"
            )
        ) {
            try await sut.integrityAssertions
        }
    }
    
    @Test("Check that 401 throws invalid token error")
    func testAssertIntegrity401() async throws {
        MockURLProtocol.handler = {
            (Data(), HTTPURLResponse(statusCode: 401))
        }
        
        await #expect(
            throws: ClientAssertionError(
                .invalidToken,
                errorDescription: "The operation couldn’t be completed. (Networking.ServerError error 401.)"
            )
        ) {
            try await sut.integrityAssertions
        }
    }
    
    @Test("Check that 500 throws txma server error")
    func testAssertIntegrity500() async throws {
        MockURLProtocol.handler = {
            (Data(), HTTPURLResponse(statusCode: 500))
        }
        
        await #expect(
            throws: ClientAssertionError(
                .serverError,
                errorDescription: "The operation couldn’t be completed. (Networking.ServerError error 500.)"
            )
        ) {
            try await sut.integrityAssertions
        }
    }
    
    @Test("Proof of possession token generator returns error cant create attestation proof of possession error")
    func testAttestationProofOfPossessionError() async throws {
        MockURLProtocol.handler = {
            (Data("""
             {
              "client_attestation": "testAttestation",
              "expires_in": 86400
             }
            """.utf8),
             HTTPURLResponse(statusCode: 200))
        }
        
        mockAttestationProofOfPossessionTokenGenerator.errorFromToken = NSError(domain: "test domain", code: 0)
        
        await #expect(
            throws: ProofOfPossessionError(
                .cantGenerateAttestationProofOfPossessionJWT,
                errorDescription: "The operation couldn’t be completed. (test domain error 0.)"
            )
        ) {
            try await sut.integrityAssertions
        }
    }
    
    @Test("DPoP token generator returns error cant create attestation proof of possession error")
    func testDPoPError() async throws {
        MockURLProtocol.handler = {
            (Data("""
             {
              "client_attestation": "testAttestation",
              "expires_in": 86400
             }
            """.utf8),
             HTTPURLResponse(statusCode: 200))
        }
        
        mockDemonstratingProofOfPossessionTokenGenerator.errorFromToken = NSError(domain: "test domain", code: 0)
        
        await #expect(
            throws: ProofOfPossessionError(
                .cantGenerateDemonstratingProofOfPossessionJWT,
                errorDescription: "The operation couldn’t be completed. (test domain error 0.)"
            )
        ) {
            try await sut.integrityAssertions
        }
    }
    
    @Test("Check that client attestation is decoded successfully")
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
        #expect(response.clientAttestation == "testAttestation")
        
        // Expiry time should be more than a day since before we made the request
        // but less than a day from now
        #expect(response.expiryDate > initialDate.addingTimeInterval(expiresIn))
        #expect(response.expiryDate < Date().addingTimeInterval(expiresIn))
    }
    
    @Test("Check that client attestation request returns a server error")
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
    
    @Test("Check that client attestation request payload results in a decoding error")
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
            throws: ClientAssertionError(
                .cantDecodeClientAssertion,
                errorDescription: "The data couldn’t be read because it isn’t in the correct format."
            )
        ) {
            try await sut
                .fetchClientAttestation(appCheckToken: UUID().uuidString)
        }
    }
    
    @Test("Check that client attestation request public key error is caught")
    func testFetchClientAttestationPublicKey() async throws {
        mockAttestationProofOfPossessionProvider.errorFromPublicKey = NSError(domain: "test domain", code: 0)
        
        await #expect(
            throws: ProofOfPossessionError(
                .cantGenerateAttestationPublicKeyJWK,
                errorDescription: "The operation couldn’t be completed. (test domain error 0.)"
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
