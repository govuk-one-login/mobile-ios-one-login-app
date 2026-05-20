import AppIntegrity

struct AppIntegrityProviderStub: AppIntegrityProvider {
    let clientAssertions: [String: String]
    let dPopAssertion: [String: String]
    let integrityAssertions: [String: String]
    
    init(clientAssertions: [String: String] = [:],
         dPopAssertion: [String: String] = [:],
         integrityAssertions: [String: String] = [:]) {
        self.clientAssertions = clientAssertions
        self.dPopAssertion = dPopAssertion
        self.integrityAssertions = integrityAssertions
    }
}
