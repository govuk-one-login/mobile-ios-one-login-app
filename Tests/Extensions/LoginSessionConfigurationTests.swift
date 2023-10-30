@testable import Authentication
@testable import OneLogin
import XCTest

final class LoginSessionConfigurationTests: XCTestCase {
    func test_oneLoginSessionConfig() throws {
        XCTAssertEqual(LoginSessionConfiguration.oneLoginSessionConfig.authorizationEndpoint, URL.oneLoginAuthorize)
        XCTAssertEqual(LoginSessionConfiguration.oneLoginSessionConfig.tokenEndpoint, URL.oneLoginToken)
        XCTAssertEqual(LoginSessionConfiguration.oneLoginSessionConfig.responseType, LoginSessionConfiguration.ResponseType.code)
        XCTAssertEqual(LoginSessionConfiguration.oneLoginSessionConfig.scopes, [.openid, .offline_access])
        XCTAssertEqual(LoginSessionConfiguration.oneLoginSessionConfig.clientID, String.oneLoginClientID)
        XCTAssertEqual(LoginSessionConfiguration.oneLoginSessionConfig.prefersEphemeralWebSession, true)
        XCTAssertEqual(LoginSessionConfiguration.oneLoginSessionConfig.redirectURI, String.oneLoginRedirect)
        XCTAssertEqual(LoginSessionConfiguration.oneLoginSessionConfig.viewThroughRate, "[Cl.Cm.P0]")
        XCTAssertEqual(LoginSessionConfiguration.oneLoginSessionConfig.locale, .en)
    }
}
