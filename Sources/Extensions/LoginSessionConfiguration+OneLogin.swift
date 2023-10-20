import Authentication
import Foundation

extension LoginSessionConfiguration {
    static func oneLogin(url: URL) -> Self {
        return LoginSessionConfiguration(authorizationEndpoint: url,
                                         responseType: .code,
                                         scopes: [.openid, .email, .phone, .offline_access],
                                         clientID: "6ttkBTo3Yk2ifegc6sHSDp4qwY",
                                         prefersEphemeralWebSession: false,
                                         redirectURI: "https://app-login-spike-www.review-b.dev.account.gov.uk/dca/app/redirect",
                                         nonce: "aEwkamaos5B",
                                         viewThroughRate: "[Cl.Cm.P0]",
                                         locale: .en)
    }
}
