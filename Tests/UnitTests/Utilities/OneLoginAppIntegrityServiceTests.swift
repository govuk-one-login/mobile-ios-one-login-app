import AppIntegrity
@testable import OneLogin
import Testing

struct OneLoginAppIntegrityServiceTests {
    @Test("Integrity assertions are retried for network error")
    func integrityAssertionNetworkError() async throws {
        let mockInterityService = MockAppIntegrityProvider()
        mockInterityService.errorThrownAssertingIntegrity = FirebaseAppCheckError(.network)
        let sut = OneLoginAppIntegrityService(integrityService: mockInterityService)
        
        do {
            _ = try await sut.integrityAssertions()
        } catch let error as FirebaseAppCheckError {
            #expect(error.kind == .network)
            #expect(await sut.errorRetries == 3)
            #expect(mockInterityService.attempts == 3)
        }
    }
    
    @Test("Integrity assertions are not retried for unknown error")
    func integrityAssertionsUnknownError() async throws {
        let mockInterityService = MockAppIntegrityProvider()
        mockInterityService.errorThrownAssertingIntegrity = FirebaseAppCheckError(.unknown)
        let sut = OneLoginAppIntegrityService(integrityService: mockInterityService)
        
        do {
            _ = try await sut.integrityAssertions()
        } catch let error as FirebaseAppCheckError {
            #expect(error.kind == .unknown)
            #expect(await sut.errorRetries == 0)
            #expect(mockInterityService.attempts == 1)
        }
    }
    
    @Test("Integrity assertions are not retried for invalid configuration error")
    func integrityAssertionsInvalidConfigurationError() async throws {
        let mockInterityService = MockAppIntegrityProvider()
        mockInterityService.errorThrownAssertingIntegrity = FirebaseAppCheckError(.invalidConfiguration)
        let sut = OneLoginAppIntegrityService(integrityService: mockInterityService)
        
        do {
            _ = try await sut.integrityAssertions()
        } catch let error as FirebaseAppCheckError {
            #expect(error.kind == .invalidConfiguration)
            #expect(await sut.errorRetries == 0)
            #expect(mockInterityService.attempts == 1)
        }
    }
    
    @Test("Integrity assertions are not retried for keychain access error")
    func integrityAssertionsKeychainAccessError() async throws {
        let mockInterityService = MockAppIntegrityProvider()
        mockInterityService.errorThrownAssertingIntegrity = FirebaseAppCheckError(.keychainAccess)
        let sut = OneLoginAppIntegrityService(integrityService: mockInterityService)
        
        do {
            _ = try await sut.integrityAssertions()
        } catch let error as FirebaseAppCheckError {
            #expect(error.kind == .keychainAccess)
            #expect(await sut.errorRetries == 0)
            #expect(mockInterityService.attempts == 1)
        }
    }
    
    @Test("Integrity assertions are not retried for keychain access error")
    func integrityAssertionsNotSupportedError() async throws {
        let mockInterityService = MockAppIntegrityProvider()
        mockInterityService.errorThrownAssertingIntegrity = FirebaseAppCheckError(.notSupported)
        let sut = OneLoginAppIntegrityService(integrityService: mockInterityService)
        
        do {
            _ = try await sut.integrityAssertions()
        } catch let error as FirebaseAppCheckError {
            #expect(error.kind == .notSupported)
            #expect(await sut.errorRetries == 0)
            #expect(mockInterityService.attempts == 1)
        }
    }
    
    @Test("Integrity assertions are not retried for generic error")
    func integrityAssertionsGenericError() async throws {
        let mockInterityService = MockAppIntegrityProvider()
        mockInterityService.errorThrownAssertingIntegrity = FirebaseAppCheckError(.generic)
        let sut = OneLoginAppIntegrityService(integrityService: mockInterityService)
        
        do {
            _ = try await sut.integrityAssertions()
        } catch let error as FirebaseAppCheckError {
            #expect(error.kind == .generic)
            #expect(await sut.errorRetries == 0)
            #expect(mockInterityService.attempts == 1)
        }
    }
    
    @Test("Integrity assertions are retried for invalid token error")
    func integrityAssertionInvalidTokenError() async throws {
        let mockInterityService = MockAppIntegrityProvider()
        mockInterityService.errorThrownAssertingIntegrity = ClientAssertionError(.invalidToken)
        let sut = OneLoginAppIntegrityService(integrityService: mockInterityService)
        
        do {
            _ = try await sut.integrityAssertions()
        } catch let error as ClientAssertionError {
            #expect(error.kind == .invalidToken)
            #expect(await sut.errorRetries == 3)
            #expect(mockInterityService.attempts == 3)
        }
    }
    
    @Test("Integrity assertions are retried for server error")
    func integrityAssertionServerError() async throws {
        let mockInterityService = MockAppIntegrityProvider()
        mockInterityService.errorThrownAssertingIntegrity = ClientAssertionError(.serverError)
        let sut = OneLoginAppIntegrityService(integrityService: mockInterityService)
        
        do {
            _ = try await sut.integrityAssertions()
        } catch let error as ClientAssertionError {
            #expect(error.kind == .serverError)
            #expect(await sut.errorRetries == 3)
            #expect(mockInterityService.attempts == 3)
        }
    }
    
    @Test("Integrity assertions are retried for cant decode client assertion error")
    func integrityAssertionCantDecodeClientAssertionError() async throws {
        let mockInterityService = MockAppIntegrityProvider()
        mockInterityService.errorThrownAssertingIntegrity = ClientAssertionError(.cantDecodeClientAssertion)
        let sut = OneLoginAppIntegrityService(integrityService: mockInterityService)
        
        do {
            _ = try await sut.integrityAssertions()
        } catch let error as ClientAssertionError {
            #expect(error.kind == .cantDecodeClientAssertion)
            #expect(await sut.errorRetries == 3)
            #expect(mockInterityService.attempts == 3)
        }
    }
    
    @Test("Integrity assertions are not retried for invalid public key error")
    func integrityAssertionsInvalidPublicKeyError() async throws {
        let mockInterityService = MockAppIntegrityProvider()
        mockInterityService.errorThrownAssertingIntegrity = ClientAssertionError(.invalidPublicKey)
        let sut = OneLoginAppIntegrityService(integrityService: mockInterityService)
        
        do {
            _ = try await sut.integrityAssertions()
        } catch let error as ClientAssertionError {
            #expect(error.kind == .invalidPublicKey)
            #expect(await sut.errorRetries == 0)
            #expect(mockInterityService.attempts == 1)
        }
    }
}
