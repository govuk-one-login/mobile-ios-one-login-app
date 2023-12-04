@testable import OneLogin
import XCTest

final class StagingAppEnvironmentTests: XCTestCase {
    func test_defaultEnvironment_retrieveFromPlist() throws {
        let sut = AppEnvironment.self
        XCTAssertEqual(sut.oneLoginAuthorize, URL(string: "https://oidc.integration.account.gov.uk/authorize"))
        XCTAssertEqual(sut.oneLoginToken, URL(string: "https://mobile.staging.account.gov.uk/token"))
        XCTAssertEqual(sut.oneLoginClientID, "sdJChz1oGajIz0O0tdPdh0CA2zW")
        XCTAssertEqual(sut.oneLoginRedirect, "https://mobile.staging.account.gov.uk/redirect")
    }
}
