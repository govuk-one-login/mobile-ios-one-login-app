import AppIntegrity

final class MockAppIntegrityProvider: AppIntegrityProvider {
    var integrityAssertions: [String: String]
    var errorThrownAssertingIntegrity: Error?
    
    init(errorThrownAssertingIntegrity: Error? = nil) throws {
        self.errorThrownAssertingIntegrity = errorThrownAssertingIntegrity
        
        if let error = errorThrownAssertingIntegrity {
            throw error
        } else {
            self.integrityAssertions = [:]
        }
    }
}
