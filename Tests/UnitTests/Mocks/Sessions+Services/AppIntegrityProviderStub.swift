import AppIntegrity

struct AppIntegrityProviderStub: AppIntegrityProvider {
    let clientAssertions: [String: String]
    let dPoPAssertion: [String: String]
    // TODO: DCMAW-20368 Delete this type
    let integrityAssertions: [String: String]
    
    let hasExpiredAttestation: Bool

    init(clientAssertions: [String: String] = [:],
         dPoPAssertion: [String: String] = [:],
         integrityAssertions: [String: String] = [:],
         hasExpiredAttestation: Bool = true) {
        self.clientAssertions = clientAssertions
        self.dPoPAssertion = dPoPAssertion
        self.integrityAssertions = integrityAssertions
        self.hasExpiredAttestation = hasExpiredAttestation
    }
}
