import AppIntegrity
import Authentication
import Foundation

extension LoginSessionConfiguration {
    @Sendable
    static func oneLoginSessionConfiguration(
        persistentSessionID: String?,
        attestationStore: AttestationStorage
    ) async throws -> Self {
        let env = AppEnvironment.self
        let shouldAttestIntegrity = try env.appIntegrityEnabled || attestationStore.validAttestation
        return await .init(
            authorizationEndpoint: env.stsAuthorize,
            tokenEndpoint: env.stsToken,
            scopes: [.openid],
            clientID: env.stsClientID,
            redirectURI: env.mobileRedirect.absoluteString,
            locale: env.isLocaleWelsh ? .cy : .en,
            persistentSessionId: persistentSessionID,
            tokenHeaders: shouldAttestIntegrity ? try await FirebaseAppIntegrityService
                .firebaseAppCheck(attestationStore: attestationStore).integrityAssertions : nil
        )
    }
}
