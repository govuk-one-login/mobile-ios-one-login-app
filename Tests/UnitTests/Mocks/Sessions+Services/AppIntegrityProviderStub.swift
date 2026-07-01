import AppIntegrity

struct AppIntegrityProviderStub: AppIntegrityProvider {
    let clientAssertions: [String: String]
    let dPoPAssertion: [String: String]
    
    let hasExpiredAttestation: Bool

    init(clientAssertions: [String: String] = [:],
         dPoPAssertion: [String: String] = [:],
         hasExpiredAttestation: Bool = true) {
        self.clientAssertions = clientAssertions
        self.dPoPAssertion = dPoPAssertion
        self.hasExpiredAttestation = hasExpiredAttestation
    }
}
