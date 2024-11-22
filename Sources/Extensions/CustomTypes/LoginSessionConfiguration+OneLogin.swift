import Authentication
import Foundation

extension LoginSessionConfiguration {
    static func oneLogin(persistentSessionId: String? = nil, tokenHeaders: [String: String]?) -> Self {
        let env = AppEnvironment.self
        return .init(authorizationEndpoint: env.callingSTSEnabled ? env.stsAuthorize : env.oneLoginAuthorize,
                     tokenEndpoint: env.callingSTSEnabled ? env.stsToken : env.oneLoginToken,
                     scopes: [.openid],
                     clientID: env.callingSTSEnabled ? env.stsClientID : env.oneLoginClientID,
                     redirectURI: env.oneLoginRedirect,
                     locale: env.isLocaleWelsh ? .cy : .en,
                     persistentSessionId: persistentSessionId,
                     tokenHeaders: tokenHeaders)
    }
}
