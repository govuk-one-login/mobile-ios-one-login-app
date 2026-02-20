import AppIntegrity

class OneLoginAppIntegrityService {
    private(set) var errorRetries = 0
    
    func integrityAssertions(
        _ integrityService: AppIntegrityProvider
    ) async throws -> [String: String] {
        do {
            return try await integrityService.integrityAssertions
        } catch let error as FirebaseAppCheckError {
            switch error.kind {
            case .network:
                return try await retryIntegrityAssertions(error, integrityService)
            case .unknown, .invalidConfiguration, .keychainAccess, .notSupported, .generic:
                throw error
            }
        } catch let error as ClientAssertionError {
            switch error.kind {
            case .invalidToken, .serverError, .cantDecodeClientAssertion:
                return try await retryIntegrityAssertions(error, integrityService)
            case .invalidPublicKey:
                throw error
            }
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
