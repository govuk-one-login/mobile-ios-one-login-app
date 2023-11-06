import Authentication

extension LoginSessionConfiguration {
    static var oneLoginSessionConfig: LoginSessionConfiguration {
        return LoginSessionConfiguration(authorizationEndpoint: AppEnvironment.oneLoginAuthorize,
                                         tokenEndpoint: AppEnvironment.oneLoginToken,
                                         scopes: [.openid],
                                         clientID: AppEnvironment.oneLoginClientID,
                                         redirectURI: AppEnvironment.oneLoginRedirect)
    }
}
