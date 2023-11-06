import Authentication
@testable import OneLogin
import XCTest

final class LoginSessionConfigurationTests: XCTestCase {
    func test_oneLoginSessionConfig() throws {
        XCTAssertEqual(LoginSessionConfiguration.oneLoginSessionConfig.authorizationEndpoint, AppEnvironment.oneLoginAuthorize)
        XCTAssertEqual(LoginSessionConfiguration.oneLoginSessionConfig.tokenEndpoint, AppEnvironment.oneLoginToken)
        XCTAssertEqual(LoginSessionConfiguration.oneLoginSessionConfig.responseType, LoginSessionConfiguration.ResponseType.code)
        XCTAssertEqual(LoginSessionConfiguration.oneLoginSessionConfig.scopes, [.openid])
        XCTAssertEqual(LoginSessionConfiguration.oneLoginSessionConfig.clientID, AppEnvironment.oneLoginClientID)
        XCTAssertEqual(LoginSessionConfiguration.oneLoginSessionConfig.prefersEphemeralWebSession, true)
        XCTAssertEqual(LoginSessionConfiguration.oneLoginSessionConfig.redirectURI, AppEnvironment.oneLoginRedirect)
        XCTAssertEqual(LoginSessionConfiguration.oneLoginSessionConfig.vectorsOfTrust, ["Cl.Cm.P0"])
        XCTAssertEqual(LoginSessionConfiguration.oneLoginSessionConfig.locale, .en)
    }
}
