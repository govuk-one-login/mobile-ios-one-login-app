@testable import OneLogin
import SecureStore
import Testing

struct AccessControlEncryptedSecureStoreManagerTests: ~Copyable {
    var sut: AccessControlEncryptedSecureStoreManager!
    
    init() throws {
        let mockv12AccessControlEncryptedSecureStore = MockSecureStoreService()
        let mockv13AccessControlEncryptedSecureStore = MockSecureStoreService()
        sut = AccessControlEncryptedSecureStoreManager(
            v12AccessControlEncryptedSecureStore: mockv12AccessControlEncryptedSecureStore,
            v13AccessControlEncryptedSecureStore: mockv13AccessControlEncryptedSecureStore
        )
        
        try sut.saveItem(
            "testRefreshTokenExpiry",
            itemName: OLString.refreshTokenExpiry
        )
        try sut.saveItem(
            "testPersistentSessionID",
            itemName: OLString.persistentSessionID
        )
        try sut.saveItem(
            "testStoredTokens",
            itemName: OLString.storedTokens
        )
    }
    
    deinit {
        sut.clearSessionData()
    }

    @Test("Clear session data deletes the refresh token, persistentSessionID and tokens")
    func delete() throws {
        #expect(try sut.readItem(OLString.storedTokens) == "testStoredTokens")
        sut.clearSessionData()
        #expect(throws: SecureStoreError.unableToRetrieveFromUserDefaults) {
            try sut.readItem(OLString.storedTokens)
        }
    }
}
