import AppIntegrity
import Authentication
import Foundation

extension LoginSessionConfiguration {
    @Sendable
    static func oneLoginSessionConfiguration(
        persistentSessionID: String?
    ) async throws -> Self {
        let env = AppEnvironment.self
        let attestationStore = SecureAttestationStore()
        // Integrity assertions should be sent if the feature flag is enabled
        // OR the user has a valid client attestation which can be used in the flow even in a potential Firebase outage
        let shouldAttestIntegrity = env.appIntegrityEnabled || !attestationStore.attestationExpired
        return await .init(
            authorizationEndpoint: env.stsAuthorize,
            tokenEndpoint: env.stsToken,
            scopes: [.openid],
            clientID: env.stsClientID,
            redirectURI: env.mobileRedirect.absoluteString,
            locale: env.isLocaleWelsh ? .cy : .en,
            persistentSessionId: persistentSessionID,
            tokenHeaders: shouldAttestIntegrity ?
            try await FirebaseAppIntegrityService
                .firebaseAppCheck(attestationStore: attestationStore)
                .integrityAssertions : nil
        )
    }
}
