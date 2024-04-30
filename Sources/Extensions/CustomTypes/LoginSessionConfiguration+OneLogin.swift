import Authentication
import Foundation

extension LoginSessionConfiguration {
    static var oneLogin: LoginSessionConfiguration {
        let env = AppEnvironment.self
        return .init(authorizationEndpoint: env.callingSTSEnabled ? env.stsAuthorize : env.oneLoginAuthorize,
                     tokenEndpoint: env.callingSTSEnabled ? env.stsToken : env.oneLoginToken,
                     scopes: env.callingSTSEnabled ? [.custom("sts")] : [.openid],
                     clientID: env.callingSTSEnabled ? env.stsClientID : env.oneLoginClientID,
                     redirectURI: env.oneLoginRedirect,
                     locale: env.isLocaleWelsh ? .cy : .en)
    }
}
