import AppIntegrity
import Networking
@testable import OneLogin
import Testing

struct OneLoginAppIntegrityServiceTests {
    @Test("Dpop assertion is returned")
    func dPoPAssertion() async throws {
        let mockInterityService = MockAppIntegrityProvider()
        let sut = OneLoginAppIntegrityService(integrityService: mockInterityService)
        
        let assertion = try await sut.dPoPAssertion()
        #expect(assertion == ["testDPoP": "testValue"])
    }
    
    @Test("Client assertions are retried for network error")
    func clientAssertionNetworkError() async throws {
        let mockInterityService = MockAppIntegrityProvider()
        mockInterityService.errorThrownAssertingIntegrity = FirebaseAppCheckError(.network)
        let sut = OneLoginAppIntegrityService(integrityService: mockInterityService)
        
        do {
            _ = try await sut.clientAssertions()
        } catch let error as FirebaseAppCheckError {
            #expect(error.kind == .network)
            #expect(await sut.attempts == 3)
            #expect(mockInterityService.attempts == 3)
        }
    }
    
    @Test("Client assertions are not retried for unknown error")
    func clientAssertionsUnknownError() async throws {
        let mockInterityService = MockAppIntegrityProvider()
        mockInterityService.errorThrownAssertingIntegrity = FirebaseAppCheckError(.unknown)
        let sut = OneLoginAppIntegrityService(integrityService: mockInterityService)
        
        do {
            _ = try await sut.clientAssertions()
        } catch let error as FirebaseAppCheckError {
            #expect(error.kind == .unknown)
            #expect(await sut.attempts == 0)
            #expect(mockInterityService.attempts == 1)
        }
    }
    
    @Test("Client assertions are not retried for invalid configuration error")
    func clientAssertionsInvalidConfigurationError() async throws {
        let mockInterityService = MockAppIntegrityProvider()
        mockInterityService.errorThrownAssertingIntegrity = FirebaseAppCheckError(.invalidConfiguration)
        let sut = OneLoginAppIntegrityService(integrityService: mockInterityService)
        
        do {
            _ = try await sut.clientAssertions()
        } catch let error as FirebaseAppCheckError {
            #expect(error.kind == .invalidConfiguration)
            #expect(await sut.attempts == 0)
            #expect(mockInterityService.attempts == 1)
        }
    }
    
    @Test("Client assertions are not retried for keychain access error")
    func clientAssertionsKeychainAccessError() async throws {
        let mockInterityService = MockAppIntegrityProvider()
        mockInterityService.errorThrownAssertingIntegrity = FirebaseAppCheckError(.keychainAccess)
        let sut = OneLoginAppIntegrityService(integrityService: mockInterityService)
        
        do {
            _ = try await sut.clientAssertions()
        } catch let error as FirebaseAppCheckError {
            #expect(error.kind == .keychainAccess)
            #expect(await sut.attempts == 0)
            #expect(mockInterityService.attempts == 1)
        }
    }
    
    @Test("Client assertions are not retried for keychain access error")
    func clientAssertionsNotSupportedError() async throws {
        let mockInterityService = MockAppIntegrityProvider()
        mockInterityService.errorThrownAssertingIntegrity = FirebaseAppCheckError(.notSupported)
        let sut = OneLoginAppIntegrityService(integrityService: mockInterityService)
        
        do {
            _ = try await sut.clientAssertions()
        } catch let error as FirebaseAppCheckError {
            #expect(error.kind == .notSupported)
            #expect(await sut.attempts == 0)
            #expect(mockInterityService.attempts == 1)
        }
    }
    
    @Test("Client assertions are not retried for generic error")
    func clientAssertionsGenericError() async throws {
        let mockInterityService = MockAppIntegrityProvider()
        mockInterityService.errorThrownAssertingIntegrity = FirebaseAppCheckError(.generic)
        let sut = OneLoginAppIntegrityService(integrityService: mockInterityService)
        
        do {
            _ = try await sut.clientAssertions()
        } catch let error as FirebaseAppCheckError {
            #expect(error.kind == .generic)
            #expect(await sut.attempts == 0)
            #expect(mockInterityService.attempts == 1)
        }
    }
    
    @Test("Client assertions are retried for invalid token error")
    func clientAssertionInvalidTokenError() async throws {
        let mockInterityService = MockAppIntegrityProvider()
        mockInterityService.errorThrownAssertingIntegrity = ClientAssertionError(.invalidToken)
        let sut = OneLoginAppIntegrityService(integrityService: mockInterityService)
        
        do {
            _ = try await sut.clientAssertions()
        } catch let error as ClientAssertionError {
            #expect(error.kind == .invalidToken)
            #expect(await sut.attempts == 3)
            #expect(mockInterityService.attempts == 3)
        }
    }
    
    @Test("Client assertions are retried for server error")
    func clientAssertionServerError() async throws {
        let mockInterityService = MockAppIntegrityProvider()
        mockInterityService.errorThrownAssertingIntegrity = ClientAssertionError(.serverError)
        let sut = OneLoginAppIntegrityService(integrityService: mockInterityService)
        
        do {
            _ = try await sut.clientAssertions()
        } catch let error as ClientAssertionError {
            #expect(error.kind == .serverError)
            #expect(await sut.attempts == 3)
            #expect(mockInterityService.attempts == 3)
        }
    }
    
    @Test("Client assertions are retried for cant decode client assertion error")
    func clientAssertionCantDecodeClientAssertionError() async throws {
        let mockInterityService = MockAppIntegrityProvider()
        mockInterityService.errorThrownAssertingIntegrity = ClientAssertionError(.cantDecodeClientAssertion)
        let sut = OneLoginAppIntegrityService(integrityService: mockInterityService)
        
        do {
            _ = try await sut.clientAssertions()
        } catch let error as ClientAssertionError {
            #expect(error.kind == .cantDecodeClientAssertion)
            #expect(await sut.attempts == 3)
            #expect(mockInterityService.attempts == 3)
        }
    }
    
    @Test("Client assertions are not retried for invalid public key error")
    func clientAssertionsInvalidPublicKeyError() async throws {
        let mockInterityService = MockAppIntegrityProvider()
        mockInterityService.errorThrownAssertingIntegrity = ClientAssertionError(.invalidPublicKey)
        let sut = OneLoginAppIntegrityService(integrityService: mockInterityService)
        
        do {
            _ = try await sut.clientAssertions()
        } catch let error as ClientAssertionError {
            #expect(error.kind == .invalidPublicKey)
            #expect(await sut.attempts == 0)
            #expect(mockInterityService.attempts == 1)
        }
    }
    
    @Test
    func correctMappingForFirebaseError_invalidConfig() async throws {
        let mockInterityService = MockAppIntegrityProvider()
        mockInterityService.errorThrownAssertingIntegrity = FirebaseAppCheckError(.invalidConfiguration)
        let sut = OneLoginAppIntegrityService(integrityService: mockInterityService)
        
        do {
            _ = try await sut.fetchClientAttestation()
        } catch let error as Networking.AppIntegrityError {
            #expect(error.kind == .appIntegrityFailed)
        }
    }
    
    @Test
    func correctMappingForFirebaseError_network() async throws {
        let mockInterityService = MockAppIntegrityProvider()
        mockInterityService.errorThrownAssertingIntegrity = FirebaseAppCheckError(.network)
        let sut = OneLoginAppIntegrityService(integrityService: mockInterityService)
        
        do {
            _ = try await sut.fetchClientAttestation()
        } catch let error as Networking.AppIntegrityError {
            #expect(error.kind == .intermittent)
        }
    }
    
    @Test
    func correctMappingForFirebaseError_generic() async throws {
        let mockInterityService = MockAppIntegrityProvider()
        mockInterityService.errorThrownAssertingIntegrity = FirebaseAppCheckError(.generic)
        let sut = OneLoginAppIntegrityService(integrityService: mockInterityService)
        
        do {
            _ = try await sut.fetchClientAttestation()
        } catch let error as Networking.AppIntegrityError {
            #expect(error.kind == .generic)
        }
    }
    
    @Test
    func correctMappingForFirebaseError_unknown() async throws {
        let mockInterityService = MockAppIntegrityProvider()
        mockInterityService.errorThrownAssertingIntegrity = FirebaseAppCheckError(.unknown)
        let sut = OneLoginAppIntegrityService(integrityService: mockInterityService)
        
        do {
            _ = try await sut.fetchClientAttestation()
        } catch let error as Networking.AppIntegrityError {
            #expect(error.kind == .generic)
        }
    }
    
    @Test
    func correctMappingForClientAssertionError_intermittent() async throws {
        let mockInterityService = MockAppIntegrityProvider()
        mockInterityService.errorThrownAssertingIntegrity = ClientAssertionError(.serverError)
        let sut = OneLoginAppIntegrityService(integrityService: mockInterityService)
        
        do {
            _ = try await sut.fetchClientAttestation()
        } catch let error as Networking.AppIntegrityError {
            #expect(error.kind == .intermittent)
        }
    }
    
    @Test
    func correctMappingForClientAssertionError_intermitted() async throws {
        let mockInterityService = MockAppIntegrityProvider()
        mockInterityService.errorThrownAssertingIntegrity = ClientAssertionError(.invalidPublicKey)
        let sut = OneLoginAppIntegrityService(integrityService: mockInterityService)
        
        do {
            _ = try await sut.fetchClientAttestation()
        } catch let error as Networking.AppIntegrityError {
            #expect(error.kind == .appIntegrityFailed)
        }
    }
    
    @Test
    func correctMappingForProofOfPossessionError() async throws {
        let mockInterityService = MockAppIntegrityProvider()
        mockInterityService.errorThrownAssertingIntegrity = ProofOfPossessionError(.cantGenerateAttestationProofOfPossessionJWT)
        let sut = OneLoginAppIntegrityService(integrityService: mockInterityService)
        
        do {
            _ = try await sut.fetchClientAttestation()
        } catch let error as Networking.AppIntegrityError {
            #expect(error.kind == .appIntegrityFailed)
        }
    }
    
    @Test
    func correctMappingForDPoPProofOfPossessionError() async throws {
        let mockInterityService = MockAppIntegrityProvider()
        mockInterityService.errorThrownAssertingIntegrity = ProofOfPossessionError(.cantGenerateAttestationProofOfPossessionJWT)
        let sut = OneLoginAppIntegrityService(integrityService: mockInterityService)
        
        do {
            _ = try await sut.fetchDPoP()
        } catch let error as Networking.AppIntegrityError {
            #expect(error.kind == .appIntegrityFailed)
        }
    }
}
