import AppIntegrity
import Authentication
import Foundation

extension LoginSessionConfiguration {
    @Sendable
    static func oneLoginSessionConfiguration(
        persistentSessionID: String?
    ) -> Self {
        let env = AppEnvironment.self
        return .init(authorizationEndpoint: env.stsAuthorize,
                     tokenEndpoint: env.stsToken,
                     scopes: [.openid],
                     clientID: env.stsClientID,
                     redirectURI: env.mobileRedirect.absoluteString,
                     locale: env.isLocaleWelsh ? .cy : .en,
                     persistentSessionId: persistentSessionID)
    }
}
