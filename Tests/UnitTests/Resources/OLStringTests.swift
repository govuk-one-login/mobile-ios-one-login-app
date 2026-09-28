@testable import OneLogin
import Testing

struct OLStringTests {
    @Test
    func test_tokenAndLogin_strings() {
        // Store IDs
        #expect(OLString.v12TokensStore == "oneLoginTokens")
        #expect(OLString.v13TokensStore == "oneLoginTokenStore")
        #expect(OLString.v12TokenInfoStore == "persistentSessionID")
        #expect(OLString.v13TokenInfoStore == "insensitiveTokenInfoStore")
        
        // Token & Login
        #expect(OLString.refreshTokenExpiry == "refreshTokenExpiry")
        #expect(OLString.accessTokenExpiry == "accessTokenExpiry")
        #expect(OLString.storedTokens == "storedTokens")
        #expect(OLString.persistentSessionID == "persistentSessionID")
        #expect(OLString.returningUser == "returningUser")
        #expect(OLString.migratedEncryptedStoreToV13 == "migratedEncryptedStoreToV13")
        #expect(OLString.migratedAccessControlEncryptedStoreToV13 == "migratedAccessControlEncryptedStoreToV13")

        // Universal Link Component
        #expect(OLString.redirect == "redirect")
        #expect(OLString.wallet == "wallet")
    }
}
