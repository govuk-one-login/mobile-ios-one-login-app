import Authentication
import Foundation

extension LoginSessionConfiguration {
    static func oneLogin(authorizeEndpoint: URL) -> Self {
        guard let redirectURL = Bundle.main.infoDictionary?["Redirect URL"] as? String else {
            fatalError("Couldn't fetch Redirect URL from plist")
        }
        return LoginSessionConfiguration(authorizationEndpoint: authorizeEndpoint,
                                         responseType: .code,
                                         scopes: [.openid, .offline_access],
                                         clientID: "sdJChz1oGajIz0O0tdPdh0CA2zW",
                                         prefersEphemeralWebSession: true,
                                         redirectURI: redirectURL,
                                         nonce: "aEwkamaos5B",
                                         viewThroughRate: "[Cl.Cm.P0]",
                                         locale: .en)
    }
}
