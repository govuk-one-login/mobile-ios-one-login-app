@testable import OneLogin
import XCTest

final class URLExtensionTests: XCTestCase {
    func test_oneLoginURLExtensions() throws {
        XCTAssertEqual(URL.oneLoginAuthorize, URL(string: "https://oidc.integration.account.gov.uk/authorize"))
        XCTAssertEqual(URL.oneLoginToken, URL(string: "https://test.com/test"))
    }
}
