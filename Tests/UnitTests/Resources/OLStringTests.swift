@testable import OneLogin
import XCTest

final class OLStringTests: XCTestCase {
    func test_tokenAndLogin_strings() throws {
        // Store IDs
        XCTAssertEqual(OLString.oneLoginTokensStore, "oneLoginTokensStore")
        XCTAssertEqual(OLString.publicTokenInfoStore, "publicTokenInfoStore")
        XCTAssertEqual(OLString.attestationStore, "attestationStore")

        // Token & Login
        XCTAssertEqual(OLString.refreshTokenExpiry, "refreshTokenExpiry")
        XCTAssertEqual(OLString.accessTokenExpiry, "accessTokenExpiry")
        XCTAssertEqual(OLString.storedTokens, "storedTokens")
        XCTAssertEqual(OLString.persistentSessionID, "persistentSessionID")
        XCTAssertEqual(OLString.returningUser, "returningUser")

        // Universal Link Component
        XCTAssertEqual(OLString.redirect, "redirect")
        XCTAssertEqual(OLString.wallet, "wallet")
        
        // Release Flags
        XCTAssertEqual(OLString.hasAccessedWalletBefore, "hasAccessedWalletBefore")
        
        // Biometrics
        XCTAssertEqual(OLString.biometricsPrompt, "localAuthPrompted")
    }
}
