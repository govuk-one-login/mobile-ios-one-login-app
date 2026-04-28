import AppIntegrity

struct AppIntegrityProviderStub: AppIntegrityProvider {
    let integrityAssertions: [String: String]
    
    init(integrityAssertions: [String: String] = [:]) {
        self.integrityAssertions = integrityAssertions
    }
}
