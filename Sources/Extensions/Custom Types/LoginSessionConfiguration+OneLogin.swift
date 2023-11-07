import Authentication

extension LoginSessionConfiguration {
    static var oneLogin: LoginSessionConfiguration {
        LoginSessionConfiguration(authorizationEndpoint: AppEnvironment.oneLoginAuthorize,
                                  tokenEndpoint: AppEnvironment.oneLoginToken,
                                  scopes: [.openid],
                                  clientID: AppEnvironment.oneLoginClientID,
                                  redirectURI: AppEnvironment.oneLoginRedirect)
    }
}
