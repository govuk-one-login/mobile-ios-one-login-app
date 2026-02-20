import AppIntegrity

class OneLoginAppIntegrityService {
    private(set) var errorRetries = 0
    
    func integrityAssertions(
        _ integrityService: AppIntegrityProvider
    ) async throws -> [String: String] {
        do {
            return try await integrityService.integrityAssertions
        } catch let error as FirebaseAppCheckError where error.kind == .network {
            return try await retryIntegrityAssertions(error, integrityService)
        } catch let error as ClientAssertionError where error.kind == .invalidToken {
            return try await retryIntegrityAssertions(error, integrityService)
        } catch let error as ClientAssertionError where error.kind == .serverError {
            return try await retryIntegrityAssertions(error, integrityService)
        } catch let error as ClientAssertionError where error.kind == .cantDecodeClientAssertion {
            return try await retryIntegrityAssertions(error, integrityService)
        }
    }
    
    private func retryIntegrityAssertions(
        _ error: Error,
        _ integrityService: AppIntegrityProvider
    ) async throws -> [String: String] {
        errorRetries += 1
        
        guard errorRetries < 3 else {
            throw error
        }
        
        try await Task.sleep(nanoseconds: 100_000_000 * UInt64(errorRetries))
        return try await integrityAssertions(integrityService)
    }
}
