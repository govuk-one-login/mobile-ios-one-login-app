import AppIntegrity
@testable import OneLogin
import Testing

struct OneLoginAppIntegrityServiceTests {
    let mockInterityService = MockAppIntegrityProvider()
    let sut = OneLoginAppIntegrityService()
    
    @Test("Integrity assertions are retried for network error")
    func integrityAssertionNetworkError() async throws {
        mockInterityService.errorThrownAssertingIntegrity = FirebaseAppCheckError(.network)
        
        do {
            _ = try await sut.integrityAssertions(mockInterityService)
        } catch let error as FirebaseAppCheckError {
            #expect(error.kind == .network)
            #expect(sut.errorRetries == 3)
        }
    }
    
    @Test("Integrity assertions are retried for invalid token error")
    func integrityAssertionInvalidTokenError() async throws {
        mockInterityService.errorThrownAssertingIntegrity = ClientAssertionError(.invalidToken)
        
        do {
            _ = try await sut.integrityAssertions(mockInterityService)
        } catch let error as ClientAssertionError {
            #expect(error.kind == .invalidToken)
            #expect(sut.errorRetries == 3)
        }
    }
    
    @Test("Integrity assertions are retried for server error")
    func integrityAssertionServerError() async throws {
        mockInterityService.errorThrownAssertingIntegrity = ClientAssertionError(.serverError)
        
        do {
            _ = try await sut.integrityAssertions(mockInterityService)
        } catch let error as ClientAssertionError {
            #expect(error.kind == .serverError)
            #expect(sut.errorRetries == 3)
        }
    }
    
    @Test("Integrity assertions are retried for cant decode client assertion error")
    func integrityAssertionCantDecodeClientAssertionError() async throws {
        mockInterityService.errorThrownAssertingIntegrity = ClientAssertionError(.cantDecodeClientAssertion)
        
        do {
            _ = try await sut.integrityAssertions(mockInterityService)
        } catch let error as ClientAssertionError {
            #expect(error.kind == .cantDecodeClientAssertion)
            #expect(sut.errorRetries == 3)
        }
    }
}
