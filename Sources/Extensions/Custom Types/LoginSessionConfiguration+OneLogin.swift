import Authentication
import Foundation

extension LoginSessionConfiguration {
    static var oneLogin: LoginSessionConfiguration {
        return LoginSessionConfiguration(authorizationEndpoint: URL.oneLoginAuthorize,
                                         tokenEndpoint: URL.oneLoginToken,
                                         scopes: [.openid, .offline_access],
                                         clientID: "sdJChz1oGajIz0O0tdPdh0CA2zW",
                                         redirectURI: String.oneLoginRedirect)
    }
}
