import Authentication

extension LoginSessionConfiguration {
    static var oneLogin: LoginSessionConfiguration {
        let env = AppEnvironment.self
        return .init(authorizationEndpoint: env.callingSTSEnabled ? env.stsLoginAuthorize : env.oneLoginAuthorize,
                     tokenEndpoint: env.oneLoginToken,
                     scopes: env.callingSTSEnabled ? [.custom("sts")] : [.openid],
                     clientID: env.callingSTSEnabled ? env.stsClientID : env.oneLoginClientID,
                     redirectURI: env.oneLoginRedirect)
    }
}
