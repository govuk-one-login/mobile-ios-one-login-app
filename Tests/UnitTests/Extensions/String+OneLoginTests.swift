@testable import OneLogin
import XCTest

final class StringTests: XCTestCase {
    func test_tokenAndLogin_strings() throws {
        // Token & Login
        XCTAssertEqual(String.accessTokenExpiry, "accessTokenExpiry")
        XCTAssertEqual(String.storedTokens, "storedTokens")
        XCTAssertEqual(String.oneLoginTokens, "oneLoginTokens")
        XCTAssertEqual(String.persistentSessionID, "persistentSessionID")
        XCTAssertEqual(String.clearWallet, "clearWallet")
        XCTAssertEqual(String.startReauth, "startReauth")
        XCTAssertEqual(String.returningUser, "returningUser")

        // Universal Link Component
        XCTAssertEqual(String.redirect, "redirect")
        XCTAssertEqual(String.wallet, "wallet")
    }
}
