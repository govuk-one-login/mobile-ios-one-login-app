import AppIntegrity

final class MockAppIntegrityProvider: AppIntegrityProvider {
    var errorThrownAssertingIntegrity: Error?
    
    var integrityAssertions: [String: String] {
        get async throws {
            if let errorThrownAssertingIntegrity {
                throw errorThrownAssertingIntegrity
            }
            return ["testAsserion": "testValue"]
        }
    }
}
