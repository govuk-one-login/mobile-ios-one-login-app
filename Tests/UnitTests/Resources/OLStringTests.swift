@testable import OneLogin
import XCTest

final class OLStringTests: XCTestCase {
    func test_tokenAndLogin_strings() throws {
        // Store IDs
        XCTAssertEqual(OLString.v12TokensStore, "oneLoginTokens")
        XCTAssertEqual(OLString.v13TokensStore, "oneLoginTokenStore")
        XCTAssertEqual(OLString.v12TokenInfoStore, "persistentSessionID")
        XCTAssertEqual(OLString.v13TokenInfoStore, "insensitiveTokenInfoStore")
        
        // Token & Login
        XCTAssertEqual(OLString.refreshTokenExpiry, "refreshTokenExpiry")
        XCTAssertEqual(OLString.accessTokenExpiry, "accessTokenExpiry")
        XCTAssertEqual(OLString.storedTokens, "storedTokens")
        XCTAssertEqual(OLString.persistentSessionID, "persistentSessionID")
        XCTAssertEqual(OLString.returningUser, "returningUser")
        XCTAssertEqual(OLString.migratedEncryptedStoreToV13, "migratedEncryptedStoreToV13")
        XCTAssertEqual(OLString.migratedAccessControlEncryptedStoreToV13, "migratedAccessControlEncryptedStoreToV13")

        // Universal Link Component
        XCTAssertEqual(OLString.redirect, "redirect")
        XCTAssertEqual(OLString.wallet, "wallet")
    }
}
