@testable import OneLoginNOW
import XCTest

final class StringTests: XCTestCase {
    func test_tokenAndLogin_strings() throws {
        XCTAssertEqual(String.accessToken, "accessToken")
        XCTAssertEqual(String.accessTokenExpiry, "accessTokenExpiry")
        XCTAssertEqual(String.oneLoginTokens, "oneLoginTokens")
    }
}
