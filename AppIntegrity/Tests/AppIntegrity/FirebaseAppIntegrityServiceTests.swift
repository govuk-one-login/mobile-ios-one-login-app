// swiftlint:disable file_length
@testable import AppIntegrity
import FirebaseAppCheck
import FirebaseCore
import Foundation
import MockAppIntegrity
import MockNetworking
@testable import Networking
import Testing

// swiftlint:disable type_body_length
struct FirebaseAppIntegrityServiceTests {
    @Test("AppCheck provider is correctly configured in debug mode")
    func testConfigureAppCheckProvider() {
        FirebaseAppIntegrityService.configure(vendorType: MockAppCheckVendor.self)
        #expect(MockAppCheckVendor.wasConfigured is AppCheckDebugProviderFactory)
    }

    @Test("Check the saved attestation and proof token are returned if valid")
    func testSavedClientAssertion() async throws {
        let mockAttestationProofOfPossessionTokenGenerator = MockProofOfPossessionTokenGenerator()
        mockAttestationProofOfPossessionTokenGenerator.header = ["mockPoPHeaderKey1": "mockPoPHeaderValue1"]
        mockAttestationProofOfPossessionTokenGenerator.payload = ["mockPoPPayloadKey1": "mockPoPPayloadValue1"]

        let mockDemonstratingProofOfPossessionTokenGenerator = MockProofOfPossessionTokenGenerator()
        mockDemonstratingProofOfPossessionTokenGenerator.header = ["mockDPoPHeaderKey1": "mockDPoPHeaderValue1"]
        mockDemonstratingProofOfPossessionTokenGenerator.payload = ["mockDPoPPayloadKey1": "mockDPoPPayloadValue1"]

        let mockAttestationStore = MockAttestationStore()
        mockAttestationStore.attestationExpired = false
        let sut: FirebaseAppIntegrityService = .makeWithMocks(
            attestationProofOfPossessionTokenGenerator: mockAttestationProofOfPossessionTokenGenerator,
            demonstratingProofOfPossessionTokenGenerator: mockDemonstratingProofOfPossessionTokenGenerator,
            attestationStore: mockAttestationStore)

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
        
    @Test("Check that the dPoPAssertion returns correct dictionary")
    func testAssertDPoP() throws {
        let mockDemonstratingProofOfPossessionTokenGenerator = MockProofOfPossessionTokenGenerator()
        mockDemonstratingProofOfPossessionTokenGenerator.header = ["mockDPoPHeaderKey1": "mockDPoPHeaderValue1"]
        mockDemonstratingProofOfPossessionTokenGenerator.payload = ["mockDPoPPayloadKey1": "mockDPoPPayloadValue1"]

        let sut: FirebaseAppIntegrityService = .makeWithMocks(demonstratingProofOfPossessionTokenGenerator: mockDemonstratingProofOfPossessionTokenGenerator)

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
    
    @Test("AppCheck vendor throws unknown error from limitedUseToken")
    func testAppCheckUnknownError() async throws {
        let mockVendor = MockAppCheckVendor()
        mockVendor.errorFromLimitedUseToken = NSError(domain: AppCheckErrorDomain, code: 0)
        let sut: FirebaseAppIntegrityService = .makeWithMocks(mockVendor: mockVendor)

        let error = await #expect(throws: FirebaseAppCheckError.self) {
            _ = try await sut.clientAssertions
        }

        #expect(error?.kind == .unknown)
        let underlyingError = try #require(error?.errorUserInfo[NSUnderlyingErrorKey] as? NSError)
        #expect(underlyingError.localizedDescription ==
                "The operation couldn’t be completed. (com.firebase.appCheck error 0.)")
    }
    
    @Test("AppCheck vendor throws network error from limitedUseToken")
    func testAppCheckNetworkError() async throws {
        let mockVendor = MockAppCheckVendor()
        mockVendor.errorFromLimitedUseToken = NSError(domain: AppCheckErrorDomain, code: 1)
        let sut: FirebaseAppIntegrityService = .makeWithMocks(mockVendor: mockVendor)

        let error = await #expect(throws: FirebaseAppCheckError.self) {
            _ = try await sut.clientAssertions
        }

        #expect(error?.kind == .network)
        let underlyingError = try #require(error?.errorUserInfo[NSUnderlyingErrorKey] as? NSError)
        #expect(underlyingError.localizedDescription ==
                "The operation couldn’t be completed. (com.firebase.appCheck error 1.)")
    }
    
    @Test("AppCheck vendor throws invalid configuration error from limitedUseToken")
    func testAppCheckInvalidconfigurationError() async throws {
        let mockVendor = MockAppCheckVendor()
        mockVendor.errorFromLimitedUseToken = NSError(domain: AppCheckErrorDomain, code: 2)
        let sut: FirebaseAppIntegrityService = .makeWithMocks(mockVendor: mockVendor)

        let error = await #expect(throws: FirebaseAppCheckError.self) {
            _ = try await sut.clientAssertions
        }

        #expect(error?.kind == .invalidConfiguration)
        let underlyingError = try #require(error?.errorUserInfo[NSUnderlyingErrorKey] as? NSError)
        #expect(underlyingError.localizedDescription ==
                "The operation couldn’t be completed. (com.firebase.appCheck error 2.)")
    }
    
    @Test("AppCheck vendor throws keychain access error from limitedUseToken")
    func testAppCheckKeychainAccessError() async throws {
        let mockVendor = MockAppCheckVendor()
        mockVendor.errorFromLimitedUseToken = NSError(domain: AppCheckErrorDomain, code: 3)
        let sut: FirebaseAppIntegrityService = .makeWithMocks(mockVendor: mockVendor)

        let error = await #expect(throws: FirebaseAppCheckError.self) {
            _ = try await sut.clientAssertions
        }

        #expect(error?.kind == .keychainAccess)
        let underlyingError = try #require(error?.errorUserInfo[NSUnderlyingErrorKey] as? NSError)
        #expect(underlyingError.localizedDescription ==
                "The operation couldn’t be completed. (com.firebase.appCheck error 3.)")
    }
    
    @Test("AppCheck vendor throws not supported error from limitedUseToken")
    func testAppCheckNotSupportedError() async throws {
        let mockVendor = MockAppCheckVendor()
        mockVendor.errorFromLimitedUseToken = NSError(domain: AppCheckErrorDomain, code: 4)
        let sut: FirebaseAppIntegrityService = .makeWithMocks(mockVendor: mockVendor)

        let error = await #expect(throws: FirebaseAppCheckError.self) {
            _ = try await sut.clientAssertions
        }

        #expect(error?.kind == .notSupported)
        let underlyingError = try #require(error?.errorUserInfo[NSUnderlyingErrorKey] as? NSError)
        #expect(underlyingError.localizedDescription ==
                "The operation couldn’t be completed. (com.firebase.appCheck error 4.)")
    }
    
    @Test("AppCheck vendor throws generic error from limitedUseToken")
    func testAppCheckGenericError() async throws {
        let mockVendor = MockAppCheckVendor()
        mockVendor.errorFromLimitedUseToken = NSError(domain: AppCheckErrorDomain, code: 5)
        let sut: FirebaseAppIntegrityService = .makeWithMocks(mockVendor: mockVendor)
        
        let error = await #expect(throws: FirebaseAppCheckError.self) {
            _ = try await sut.clientAssertions
        }

        #expect(error?.kind == .generic)
        let underlyingError = try #require(error?.errorUserInfo[NSUnderlyingErrorKey] as? NSError)
        #expect(underlyingError.localizedDescription ==
                "The operation couldn’t be completed. (com.firebase.appCheck error 5.)")
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

        let mockDemonstratingProofOfPossessionTokenGenerator = MockProofOfPossessionTokenGenerator()
        mockDemonstratingProofOfPossessionTokenGenerator.errorFromToken = NSError(domain: "test domain", code: 0)
        let sut: FirebaseAppIntegrityService = .makeWithMocks(demonstratingProofOfPossessionTokenGenerator: mockDemonstratingProofOfPossessionTokenGenerator)

        let error = await #expect(throws: ProofOfPossessionError.self) {
            _ = try await sut.dPoPAssertion
        }

        #expect(error?.kind == .cantGenerateDemonstratingProofOfPossessionJWT)
        let underlyingError = try #require(error?.errorUserInfo[NSUnderlyingErrorKey] as? NSError)
        #expect(underlyingError.localizedDescription ==
                "The operation couldn’t be completed. (test domain error 0.)")
    }

    @Test("Check that client attestation request public key error is caught")
    func testFetchClientAttestationPublicKey() async throws {
        let mockAttestationProofOfPossessionProvider = MockProofOfPossessionProvider()
        mockAttestationProofOfPossessionProvider.errorFromPublicKey = NSError(domain: "test domain", code: 0)
        let sut: FirebaseAppIntegrityService = .makeWithMocks(attestationProofOfPossessionProvider: mockAttestationProofOfPossessionProvider)

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

@Suite(.serialized, .tags(.networking))
struct FirebaseAppIntegrityServiceNetworkingTests {
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

        let mockAttestationProofOfPossessionTokenGenerator = MockProofOfPossessionTokenGenerator()
        mockAttestationProofOfPossessionTokenGenerator.header = ["mockPoPHeaderKey1": "mockPoPHeaderValue1"]
        mockAttestationProofOfPossessionTokenGenerator.payload = ["mockPoPPayloadKey1": "mockPoPPayloadValue1"]

        let mockDemonstratingProofOfPossessionTokenGenerator = MockProofOfPossessionTokenGenerator()
        mockDemonstratingProofOfPossessionTokenGenerator.header = ["mockDPoPHeaderKey1": "mockDPoPHeaderValue1"]
        mockDemonstratingProofOfPossessionTokenGenerator.payload = ["mockDPoPPayloadKey1": "mockDPoPPayloadValue1"]

        let mockAttestationStore = MockAttestationStore()
        let sut: FirebaseAppIntegrityService = .makeWithMocks(
            attestationProofOfPossessionTokenGenerator: mockAttestationProofOfPossessionTokenGenerator,
            demonstratingProofOfPossessionTokenGenerator: mockDemonstratingProofOfPossessionTokenGenerator,
            attestationStore: mockAttestationStore)

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

        let sut: FirebaseAppIntegrityService = .makeWithMocks()

        let error = await #expect(throws: ClientAssertionError.self) {
            _ = try await sut.clientAssertions
        }

        #expect(error?.kind == .cantDecodeClientAssertion)
        let underlyingError = try #require(error?.errorUserInfo[NSUnderlyingErrorKey] as? NSError)
        #expect(underlyingError.localizedDescription ==
                "The data couldn’t be read because it isn’t in the correct format.")
    }
    
    @Test("Check that 400 throws invalid public key error")
    func testAssertIntegrity400() async throws {
        MockURLProtocol.handler = {
            (Data(), HTTPURLResponse(statusCode: 400))
        }
        
        let sut: FirebaseAppIntegrityService = .makeWithMocks()
        
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
        
        let sut: FirebaseAppIntegrityService = .makeWithMocks()
        
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
        
        let sut: FirebaseAppIntegrityService = .makeWithMocks()
        
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
        
        let mockAttestationProofOfPossessionTokenGenerator = MockProofOfPossessionTokenGenerator()
        mockAttestationProofOfPossessionTokenGenerator.errorFromToken = NSError(domain: "test domain", code: 0)
        let sut: FirebaseAppIntegrityService = .makeWithMocks(attestationProofOfPossessionTokenGenerator: mockAttestationProofOfPossessionTokenGenerator)

        let error = await #expect(throws: ProofOfPossessionError.self) {
            _ = try await sut.clientAssertions
        }

        #expect(error?.kind == .cantGenerateAttestationProofOfPossessionJWT)
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
        let sut: FirebaseAppIntegrityService = .makeWithMocks()
        
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
        let response = Data()
        MockURLProtocol.handler = {
            (response, HTTPURLResponse(statusCode: 400))
        }
        let sut: FirebaseAppIntegrityService = .makeWithMocks()
        
        await #expect(
            throws: Networking.ServerError(endpoint: "client-attestation", errorCode: 400, response: response)
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

extension Tag {
    /// Identify tests that exercise the networking layer
    @Tag static var networking: Self
}
