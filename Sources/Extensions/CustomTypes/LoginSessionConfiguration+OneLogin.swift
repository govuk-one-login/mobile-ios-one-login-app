import Authentication

extension LoginSessionConfiguration {
    static var oneLogin: LoginSessionConfiguration {
        .init(authorizationEndpoint: AppEnvironment.callingSTSEnabled ? AppEnvironment.stsLoginAuthorize : AppEnvironment.oneLoginAuthorize,
              tokenEndpoint: AppEnvironment.oneLoginToken,
              scopes: AppEnvironment.callingSTSEnabled ? [.sts] : [.openid],
              clientID: AppEnvironment.callingSTSEnabled ? AppEnvironment.stsClientID : AppEnvironment.oneLoginClientID,
              redirectURI: AppEnvironment.oneLoginRedirect)
    }
}
