import Authentication
@testable import OneLogin
import XCTest

final class LoginSessionConfigurationTests: XCTestCase {
    func test_oneLoginSessionConfig() throws {
        XCTAssertEqual(LoginSessionConfiguration.oneLogin.authorizationEndpoint, AppEnvironment.oneLoginAuthorize)
        XCTAssertEqual(LoginSessionConfiguration.oneLogin.tokenEndpoint, AppEnvironment.oneLoginToken)
        XCTAssertEqual(LoginSessionConfiguration.oneLogin.responseType, LoginSessionConfiguration.ResponseType.code)
        XCTAssertEqual(LoginSessionConfiguration.oneLogin.scopes, [.openid])
        XCTAssertEqual(LoginSessionConfiguration.oneLogin.clientID, AppEnvironment.oneLoginClientID)
        XCTAssertEqual(LoginSessionConfiguration.oneLogin.prefersEphemeralWebSession, true)
        XCTAssertEqual(LoginSessionConfiguration.oneLogin.redirectURI, AppEnvironment.oneLoginRedirect)
        XCTAssertEqual(LoginSessionConfiguration.oneLogin.vectorsOfTrust, ["Cl.Cm.P0"])
        if UserDefaults.standard.stringArray(forKey: "AppleLanguages")?.first?.prefix(2) == "cy" {
            XCTAssertEqual(LoginSessionConfiguration.oneLogin.locale, .cy)
        } else {
            XCTAssertEqual(LoginSessionConfiguration.oneLogin.locale, .en)
        }
    }
}
