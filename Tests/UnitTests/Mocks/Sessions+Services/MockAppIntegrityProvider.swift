import AppIntegrity

final class MockAppIntegrityProvider: AppIntegrityProvider {
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
    
    var dPoPAssertion: [String: String] = ["testAsserion": "testValue"]
    
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
