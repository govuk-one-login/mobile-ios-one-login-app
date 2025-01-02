import AppIntegrity
import Authentication
import Foundation

extension LoginSessionConfiguration {
    @Sendable
    static func oneLoginSessionConfiguration(
        persistentSessionID: String?
    ) async throws -> Self {
        let env = AppEnvironment.self
        let shouldAttestIntegrity = env.appIntegrityEnabled || UserDefaults.standard.validAttestation
        return await .init(
            authorizationEndpoint: env.stsAuthorize,
            tokenEndpoint: env.stsToken,
            scopes: [.openid],
            clientID: env.stsClientID,
            redirectURI: env.mobileRedirect.absoluteString,
            locale: env.isLocaleWelsh ? .cy : .en,
            persistentSessionId: persistentSessionID,
            tokenHeaders: shouldAttestIntegrity ? try await FirebaseAppIntegrityService
                .firebaseAppCheck().integrityAssertions : nil
        )
    }
}
