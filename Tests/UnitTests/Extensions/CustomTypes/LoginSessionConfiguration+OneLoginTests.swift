import AppIntegrity
import Authentication
import Testing
@testable import OneLogin

struct LoginSessionConfigurationOneLoginTests {

    @Test func makeOneLoginSessionConfiguration() async throws {
        
        let appIntegrityProvider = { return AppIntegrityProviderStub(hasExpiredAttestation: false) }
        
        await #expect(throws: Never.self) {
            try await LoginSessionConfiguration.oneLoginSessionConfiguration(persistentSessionID: nil, appIntegrityProvider: appIntegrityProvider)
        }
    }
    
    @Test func makeOneLoginSessionConfigurationWithExpiredAttestation() async throws {
        
        let appIntegrityProvider = { return AppIntegrityProviderStub(hasExpiredAttestation: true) }
        
        await #expect(throws: Never.self) {
            try await LoginSessionConfiguration.oneLoginSessionConfiguration(persistentSessionID: nil, appIntegrityProvider: appIntegrityProvider)
        }
    }

}
