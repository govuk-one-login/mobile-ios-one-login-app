import AppIntegrity
import Networking

final class MockAppIntegrityProvider: AppIntegrityProvider {
    let hasExpiredAttestation: Bool = true
    
    var attempts = 0
    var errorThrownAssertingIntegrity: Error?
    
    var clientAssertions: [String: String] {
        get throws {
            self.attempts += 1
            if let errorThrownAssertingIntegrity {
                throw errorThrownAssertingIntegrity
            }
            return ["testAsserion": "testValue"]
        }
    }
    
    var dPoPAssertion: [String: String] = ["testDPoP": "testValue"]
}

extension MockAppIntegrityProvider: ClientAttestationProvider, DPoPProvider {
    func fetchClientAttestation() async throws -> [String: String] {
        do {
            return try clientAssertions
        } catch let error as FirebaseAppCheckError {
            switch error.kind {
            case .network:
                throw AppIntegrityError(.intermittent, originalError: error)
            case .generic:
                throw AppIntegrityError(.generic, originalError: error)
            case .unknown, .invalidConfiguration, .keychainAccess, .notSupported:
                throw AppIntegrityError(.appIntegrityFailed, originalError: error)
            }
        } catch let error as ClientAssertionError {
            switch error.kind {
            case .invalidToken, .serverError, .cantDecodeClientAssertion:
                throw AppIntegrityError(.intermittent, originalError: error)
            case .invalidPublicKey:
                throw AppIntegrityError(.appIntegrityFailed, originalError: error)
            }
        } catch let error as ProofOfPossessionError {
            throw AppIntegrityError(.appIntegrityFailed, originalError: error)
        }
    }
    
    func fetchDPoP() async throws -> [String: String] {
        return dPoPAssertion
    }
}
