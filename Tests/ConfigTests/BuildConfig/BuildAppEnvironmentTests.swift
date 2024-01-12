@testable import OneLogin
import XCTest

final class BuildAppEnvironmentTests: XCTestCase {
    func test_defaultEnvironment_retrieveFromPlist() throws {
        let sut = AppEnvironment.self
        XCTAssertEqual(sut.oneLoginAuthorize, URL(string: "https://auth-stub.mobile.build.account.gov.uk/authorize"))
        XCTAssertEqual(sut.oneLoginToken, URL(string: "https://mobile.build.account.gov.uk/token"))
        XCTAssertEqual(sut.oneLoginClientID, "TEST_CLIENT_ID")
        XCTAssertEqual(sut.oneLoginRedirect, "https://mobile.build.account.gov.uk/redirect")
        XCTAssertFalse(sut.callingSTSEnabled)
    }
}
