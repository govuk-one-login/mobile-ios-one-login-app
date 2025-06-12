@testable import OneLogin
import XCTest

final class OLStringTests: XCTestCase {
    func test_tokenAndLogin_strings() throws {
        // Token & Login
        XCTAssertEqual(OLString.accessTokenExpiry, "accessTokenExpiry")
        XCTAssertEqual(OLString.storedTokens, "storedTokens")
        XCTAssertEqual(OLString.oneLoginTokens, "oneLoginTokens")
        XCTAssertEqual(OLString.persistentSessionID, "persistentSessionID")
        XCTAssertEqual(OLString.returningUser, "returningUser")

        // Universal Link Component
        XCTAssertEqual(OLString.redirect, "redirect")
        XCTAssertEqual(OLString.wallet, "wallet")
    }
}
