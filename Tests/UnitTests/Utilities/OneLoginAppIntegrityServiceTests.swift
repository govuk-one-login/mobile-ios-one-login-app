import AppIntegrity
@testable import OneLogin
import Testing

struct OneLoginAppIntegrityServiceTests {
    let mockInterityService = MockAppIntegrityProvider()
    
    @Test("Integrity assertions are retried for network error")
    func integrityAssertionsNetworkError() async throws {
        mockInterityService.errorThrownAssertingIntegrity = FirebaseAppCheckError(.network)
        let sut = OneLoginAppIntegrityService()
        
        do {
            _ = try await sut.integrityAssertions(mockInterityService)
        } catch let error as FirebaseAppCheckError {
            #expect(error.kind == .network)
            #expect(sut.errorRetries == 3)
        }
    }
    
    @Test("Integrity assertions are not retried for unknown error")
    func integrityAssertionsUnknownError() async throws {
        mockInterityService.errorThrownAssertingIntegrity = FirebaseAppCheckError(.unknown)
        let sut = OneLoginAppIntegrityService()
        
        do {
            _ = try await sut.integrityAssertions(mockInterityService)
        } catch let error as FirebaseAppCheckError {
            #expect(error.kind == .unknown)
            #expect(sut.errorRetries == 0)
        }
    }
    
    @Test("Integrity assertions are not retried for invalid configuration error")
    func integrityAssertionsInvalidConfigurationError() async throws {
        mockInterityService.errorThrownAssertingIntegrity = FirebaseAppCheckError(.invalidConfiguration)
        let sut = OneLoginAppIntegrityService()
        
        do {
            _ = try await sut.integrityAssertions(mockInterityService)
        } catch let error as FirebaseAppCheckError {
            #expect(error.kind == .invalidConfiguration)
            #expect(sut.errorRetries == 0)
        }
    }
    
    @Test("Integrity assertions are not retried for keychain access error")
    func integrityAssertionsKeychainAccessError() async throws {
        mockInterityService.errorThrownAssertingIntegrity = FirebaseAppCheckError(.keychainAccess)
        let sut = OneLoginAppIntegrityService()
        
        do {
            _ = try await sut.integrityAssertions(mockInterityService)
        } catch let error as FirebaseAppCheckError {
            #expect(error.kind == .keychainAccess)
            #expect(sut.errorRetries == 0)
        }
    }
    
    @Test("Integrity assertions are not retried for keychain access error")
    func integrityAssertionsNotSupportedError() async throws {
        mockInterityService.errorThrownAssertingIntegrity = FirebaseAppCheckError(.notSupported)
        let sut = OneLoginAppIntegrityService()
        
        do {
            _ = try await sut.integrityAssertions(mockInterityService)
        } catch let error as FirebaseAppCheckError {
            #expect(error.kind == .notSupported)
            #expect(sut.errorRetries == 0)
        }
    }
    
    @Test("Integrity assertions are not retried for generic error")
    func integrityAssertionsGenericError() async throws {
        mockInterityService.errorThrownAssertingIntegrity = FirebaseAppCheckError(.generic)
        let sut = OneLoginAppIntegrityService()
        
        do {
            _ = try await sut.integrityAssertions(mockInterityService)
        } catch let error as FirebaseAppCheckError {
            #expect(error.kind == .generic)
            #expect(sut.errorRetries == 0)
        }
    }
    
    @Test("Integrity assertions are retried for invalid token error")
    func integrityAssertionsInvalidTokenError() async throws {
        mockInterityService.errorThrownAssertingIntegrity = ClientAssertionError(.invalidToken)
        let sut = OneLoginAppIntegrityService()
        
        do {
            _ = try await sut.integrityAssertions(mockInterityService)
        } catch let error as ClientAssertionError {
            #expect(error.kind == .invalidToken)
            #expect(sut.errorRetries == 3)
        }
    }
    
    @Test("Integrity assertions are retried for server error")
    func integrityAssertionsServerError() async throws {
        mockInterityService.errorThrownAssertingIntegrity = ClientAssertionError(.serverError)
        let sut = OneLoginAppIntegrityService()
        
        do {
            _ = try await sut.integrityAssertions(mockInterityService)
        } catch let error as ClientAssertionError {
            #expect(error.kind == .serverError)
            #expect(sut.errorRetries == 3)
        }
    }
    
    @Test("Integrity assertions are retried for cant decode client assertion error")
    func integrityAssertionsCantDecodeClientAssertionError() async throws {
        mockInterityService.errorThrownAssertingIntegrity = ClientAssertionError(.cantDecodeClientAssertion)
        let sut = OneLoginAppIntegrityService()
        
        do {
            _ = try await sut.integrityAssertions(mockInterityService)
        } catch let error as ClientAssertionError {
            #expect(error.kind == .cantDecodeClientAssertion)
            #expect(sut.errorRetries == 3)
        }
    }
    
    @Test("Integrity assertions are not retried for any other ClientAssertionError")
    func integrityAssertionsClientAssertionError() async throws {
        mockInterityService.errorThrownAssertingIntegrity = ClientAssertionError(.invalidPublicKey)
        let sut = OneLoginAppIntegrityService()
        
        await #expect(
            throws: ClientAssertionError(.invalidPublicKey)
        ) {
            try await sut.integrityAssertions(mockInterityService)
        }
    }
}
