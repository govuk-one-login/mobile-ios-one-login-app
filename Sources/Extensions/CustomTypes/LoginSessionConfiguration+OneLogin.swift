import AppIntegrity
import Authentication
import Foundation

extension LoginSessionConfiguration {
    static func oneLoginWithAppIntegrity(
        persistentSessionID: String? = nil
    ) async throws -> Self {
        try await oneLoginWithAppIntegrity(
            persistentSessionID: persistentSessionID,
            appIntegrityService: .firebaseAppCheck()
        )
    }
    
    static func oneLoginWithAppIntegrity(
        persistentSessionID: String? = nil,
        appIntegrityService: AppIntegrityProvider
    ) async throws -> Self {
        guard AppEnvironment.appIntegrityEnabled else {
            return .oneLogin(persistentSessionID: persistentSessionID)
        }
        let attestationHeaders = try await appIntegrityService.assertIntegrity()
        return oneLogin(
            persistentSessionID: persistentSessionID,
            tokenHeaders: attestationHeaders
        )
    }
    
    static func oneLogin(
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
