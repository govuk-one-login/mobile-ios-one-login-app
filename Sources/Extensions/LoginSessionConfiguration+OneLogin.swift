import Authentication
import Foundation

extension LoginSessionConfiguration {
    static func oneLogin(authorizeEndpoint: URL) -> Self {
        guard let redirectURL = Bundle.main.infoDictionary?["Redirect URL"] as? String else {
            fatalError("Couldn't fetch Redirect URL from plist")
        }
        return LoginSessionConfiguration(authorizationEndpoint: authorizeEndpoint,
                                         responseType: .code,
                                         scopes: [.openid, .email, .phone, .offline_access],
                                         clientID: "6ttkBTo3Yk2ifegc6sHSDp4qwY",
                                         prefersEphemeralWebSession: false,
                                         redirectURI: redirectURL,
                                         nonce: "aEwkamaos5B",
                                         viewThroughRate: "[Cl.Cm.P0]",
                                         locale: .en)
    }
}
