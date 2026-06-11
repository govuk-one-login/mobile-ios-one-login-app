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
    
    // TODO: DCMAW-20368 Delete this type
    var integrityAssertions: [String: String] {
        get throws {
            self.attempts += 1
            if let errorThrownAssertingIntegrity {
                throw errorThrownAssertingIntegrity
            }
            return ["testAsserion": "testValue"]
        }
    }
}

extension MockAppIntegrityProvider: ClientAttestationProvider, DPoPProvider {
    func fetchClientAttestation() async throws -> [String: String] {
        return try clientAssertions
    }
    
    func fetchDPoP() async throws -> [String: String] {
        return dPoPAssertion
    }
}
