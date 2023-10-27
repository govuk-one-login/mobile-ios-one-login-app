import Authentication

extension LoginSessionConfiguration {
    static var oneLoginSessionConfig: LoginSessionConfiguration {
        return LoginSessionConfiguration(authorizationEndpoint: .oneLoginAuthorize,
                                         tokenEndpoint: .oneLoginToken,
                                         scopes: [.openid, .offline_access],
                                         clientID: .oneLoginClientID,
                                         redirectURI: .oneLoginRedirect)
    }
}
