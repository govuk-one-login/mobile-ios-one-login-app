import AppIntegrity
import Authentication
import Foundation

extension LoginSessionConfiguration {
    @Sendable
    static func oneLoginSessionConfiguration(
        persistentSessionID: String? = nil
    ) async throws -> Self {
        try await oneLoginSessionConfiguration(
            persistentSessionID: persistentSessionID,
            appIntegrityService: FirebaseAppIntegrityService.firebaseAppCheck
        )
    }

    static func oneLoginSessionConfiguration(
        persistentSessionID: String? = nil,
        appIntegrityService: () throws -> AppIntegrityProvider
    ) async throws -> Self {
        guard AppEnvironment.appIntegrityEnabled else {
            return .createSessionConfiguration(persistentSessionID: persistentSessionID)
        }
        let attestationHeaders = try await appIntegrityService().assertIntegrity()
        return createSessionConfiguration(
            persistentSessionID: persistentSessionID,
            tokenHeaders: attestationHeaders
        )
    }
    
    private static func createSessionConfiguration(
        persistentSessionID: String? = nil,
        tokenHeaders: [String: String]? = nil
    ) -> Self {
        let env = AppEnvironment.self
        return .init(authorizationEndpoint: env.stsAuthorize,
                     tokenEndpoint: env.stsToken,
                     scopes: [.openid],
                     clientID: env.stsClientID,
                     redirectURI: env.mobileRedirect.absoluteString,
                     locale: env.isLocaleWelsh ? .cy : .en,
                     persistentSessionId: persistentSessionID,
                     tokenHeaders: tokenHeaders)
    }
}
