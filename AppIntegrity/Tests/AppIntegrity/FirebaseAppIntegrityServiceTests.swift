@testable import AppIntegrity
import FirebaseAppCheck
import FirebaseCore
import Foundation
import MockNetworking
@testable import Networking
import Testing

// swiftlint:disable type_body_length
@Suite(.serialized)
struct FirebaseAppIntegrityServiceTests: ~Copyable {
    let mockVendor: MockAppCheckVendor
    let mockAttestationProofOfPossessionProvider: MockProofOfPossessionProvider
    let mockAttestationProofOfPossessionTokenGenerator: MockProofOfPossessionTokenGenerator
    let mockDemonstratingProofOfPossessionTokenGenerator: MockProofOfPossessionTokenGenerator
    let mockAttestationStore: MockAttestationStore
    let networkClient: AppIntegrityNetworkClient
    let sut: FirebaseAppIntegrityService
    
    init() throws {
        MockURLProtocol.clear()
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [
            MockURLProtocol.self
        ]
        
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
    
    deinit {
        MockURLProtocol.clear()
    }
    
    @Test("AppCheck provider is correctly configured in debug mode")
    func testConfigureAppCheckProvider() {
        FirebaseAppIntegrityService.configure(vendorType: MockAppCheckVendor.self)
        #expect(MockAppCheckVendor.wasConfigured is AppCheckDebugProviderFactory)
    }
    
    @Test("Check the saved attestation and proof token are returned if valid")
    func testSavedClientAssertion() async throws {
        mockAttestationProofOfPossessionTokenGenerator.header = ["mockPoPHeaderKey1": "mockPoPHeaderValue1"]
        mockAttestationProofOfPossessionTokenGenerator.payload = ["mockPoPPayloadKey1": "mockPoPPayloadValue1"]
        
        mockDemonstratingProofOfPossessionTokenGenerator.header = ["mockDPoPHeaderKey1": "mockDPoPHeaderValue1"]
        mockDemonstratingProofOfPossessionTokenGenerator.payload = ["mockDPoPPayloadKey1": "mockDPoPPayloadValue1"]
        
        mockAttestationStore.attestationExpired = false
        
        let integrityResponse = try await sut.clientAssertions
        
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
    }
    
    @Test("Check that the assertIntegrity returns correct dictionary")
    func testAssertClientResponse() async throws {
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
        
        let integrityResponse = try await sut.clientAssertions
        
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
            mockAttestationStore.mockStorage["attestationJWT"] as? String == "testAttestation"
        )
        
        if #available(iOS 15.0, *) {
            #expect(
                (mockAttestationStore.mockStorage["attestationExpiry"] as? Date)?
                    .formatted(.dateTime) == Date(timeIntervalSinceNow: 86400).formatted(.dateTime)
            )
        }
    }
    
    @Test("Check that the dPoPAssertion returns correct dictionary")
    func testAssertDPoP() throws {
        mockDemonstratingProofOfPossessionTokenGenerator.header = ["mockDPoPHeaderKey1": "mockDPoPHeaderValue1"]
        mockDemonstratingProofOfPossessionTokenGenerator.payload = ["mockDPoPPayloadKey1": "mockDPoPPayloadValue1"]
        
        let integrityResponse = try sut.dPoPAssertion
        
        #expect(
            integrityResponse["DPoP"]?
                .contains(#""mockDPoPHeaderKey1": "mockDPoPHeaderValue1""#) ?? false
        )
        
        #expect(
            integrityResponse["DPoP"]?
                .contains(#""mockDPoPPayloadKey1": "mockDPoPPayloadValue1""#) ?? false
        )
    }
        
    @Test("Error thrown by App Check vendor limitedUseToken is mapped to FirebaseAppCheckErrorType",
          arguments: [(AppCheckErrorCode(.unknown), FirebaseAppCheckErrorType.unknown),
                      (AppCheckErrorCode(.serverUnreachable), FirebaseAppCheckErrorType.network),
                      (AppCheckErrorCode(.invalidConfiguration), FirebaseAppCheckErrorType.invalidConfiguration),
                      (AppCheckErrorCode(.keychain), FirebaseAppCheckErrorType.keychainAccess),
                      (AppCheckErrorCode(.unsupported), FirebaseAppCheckErrorType.notSupported),
                      (AppCheckErrorCode(AppCheckErrorCode.Code(rawValue: 5)!), FirebaseAppCheckErrorType.generic)])
    func testAppCheck(errorFromLimitedUseToken: AppCheckErrorCode, map kind: FirebaseAppCheckErrorType) async throws {
        mockVendor.errorFromLimitedUseToken = errorFromLimitedUseToken
        
        let error = try #require(await #expect(throws: FirebaseAppCheckError.self) {
            _ = try await sut.clientAssertions
        })

        #expect(error.kind == kind)
        let underlyingError = try #require(error.errorUserInfo[NSUnderlyingErrorKey] as? NSError)
        #expect(underlyingError.localizedDescription ==
                "The operation couldn’t be completed. (com.firebase.appCheck error \(errorFromLimitedUseToken.errorCode).)")
    }
    
    @Test("Check that 400 throws invalid public key error")
    func testAssertIntegrity400() async throws {
        MockURLProtocol.handler = {
            (Data(), HTTPURLResponse(statusCode: 400))
        }
        
        let error = await #expect(throws: ClientAssertionError.self) {
            _ = try await sut.clientAssertions
        }

        #expect(error?.kind == .invalidPublicKey)
        let underlyingError = try #require(error?.errorUserInfo[NSUnderlyingErrorKey] as? NSError)
        #expect(underlyingError.localizedDescription ==
                "The operation couldn’t be completed. (Networking.ServerError error 400.)")
    }
    
    @Test("Check that 401 throws invalid token error")
    func testAssertIntegrity401() async throws {
        MockURLProtocol.handler = {
            (Data(), HTTPURLResponse(statusCode: 401))
        }
        
        let error = await #expect(throws: ClientAssertionError.self) {
            _ = try await sut.clientAssertions
        }

        #expect(error?.kind == .invalidToken)
        let underlyingError = try #require(error?.errorUserInfo[NSUnderlyingErrorKey] as? NSError)
        #expect(underlyingError.localizedDescription ==
                "The operation couldn’t be completed. (Networking.ServerError error 401.)")
    }
    
    @Test("Check that 500 throws txma server error")
    func testAssertIntegrity500() async throws {
        MockURLProtocol.handler = {
            (Data(), HTTPURLResponse(statusCode: 500))
        }
        
        let error = await #expect(throws: ClientAssertionError.self) {
            _ = try await sut.clientAssertions
        }

        #expect(error?.kind == .serverError)
        let underlyingError = try #require(error?.errorUserInfo[NSUnderlyingErrorKey] as? NSError)
        #expect(underlyingError.localizedDescription ==
                "The operation couldn’t be completed. (Networking.ServerError error 500.)")
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
        
        let error = await #expect(throws: ProofOfPossessionError.self) {
            _ = try await sut.clientAssertions
        }

        #expect(error?.kind == .cantGenerateAttestationProofOfPossessionJWT)
        let underlyingError = try #require(error?.errorUserInfo[NSUnderlyingErrorKey] as? NSError)
        #expect(underlyingError.localizedDescription ==
                "The operation couldn’t be completed. (test domain error 0.)")
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
        
        let error = await #expect(throws: ProofOfPossessionError.self) {
            _ = try await sut.dPoPAssertion
        }

        #expect(error?.kind == .cantGenerateDemonstratingProofOfPossessionJWT)
        let underlyingError = try #require(error?.errorUserInfo[NSUnderlyingErrorKey] as? NSError)
        #expect(underlyingError.localizedDescription ==
                "The operation couldn’t be completed. (test domain error 0.)")
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
        
        let error = await #expect(throws: ClientAssertionError.self) {
            _ = try await sut.clientAssertions
        }

        #expect(error?.kind == .cantDecodeClientAssertion)
        let underlyingError = try #require(error?.errorUserInfo[NSUnderlyingErrorKey] as? NSError)
        #expect(underlyingError.localizedDescription ==
                "The data couldn’t be read because it isn’t in the correct format.")
    }
    
    @Test("Check that client attestation request public key error is caught")
    func testFetchClientAttestationPublicKey() async throws {
        mockAttestationProofOfPossessionProvider.errorFromPublicKey = NSError(domain: "test domain", code: 0)
        
        await #expect(
            throws: ProofOfPossessionError(
                .cantGenerateAttestationPublicKeyJWK,
                reason: "The operation couldn’t be completed. (test domain error 0.)"
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
