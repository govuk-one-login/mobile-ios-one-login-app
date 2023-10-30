import Authentication

extension LoginSessionConfiguration {
    static var oneLoginSessionConfig: LoginSessionConfiguration {
        return LoginSessionConfiguration(authorizationEndpoint: AppEnvironment.oneLoginAuthorize,
                                         tokenEndpoint: AppEnvironment.oneLoginToken,
                                         scopes: [.openid, .offline_access],
                                         clientID: AppEnvironment.oneLoginClientID,
                                         redirectURI: AppEnvironment.oneLoginRedirect)
    }
}
