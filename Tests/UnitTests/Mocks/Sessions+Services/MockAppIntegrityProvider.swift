import AppIntegrity

final class MockAppIntegrityProvider: AppIntegrityProvider {
    var attempts = 0
    var errorThrownAssertingIntegrity: Error?
    
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
