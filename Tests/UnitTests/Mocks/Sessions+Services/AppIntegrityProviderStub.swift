import AppIntegrity

struct AppIntegrityProviderStub: AppIntegrityProvider {
    let clientAssertions: [String: String]
    let dPopAssertion: [String: String]
    // TODO: DCMAW-20368 Delete this type
    let integrityAssertions: [String: String]
    
    init(clientAssertions: [String: String] = [:],
         dPopAssertion: [String: String] = [:],
         integrityAssertions: [String: String] = [:]) {
        self.clientAssertions = clientAssertions
        self.dPopAssertion = dPopAssertion
        self.integrityAssertions = integrityAssertions
    }
}
