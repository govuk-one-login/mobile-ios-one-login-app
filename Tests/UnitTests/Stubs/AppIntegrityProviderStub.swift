import AppIntegrity

struct AppIntegrityProviderStub: AppIntegrityProvider {
    let integrityAssertions: [String : String] = [:]
}
