@testable import OneLogin
import SecureStore
import Testing

struct EncryptedSecureStoreManagerTests: ~Copyable {
    var sut: EncryptedSecureStoreManager!
    
    init() throws {
        let mockv12AccessControlEncryptedSecureStore = MockSecureStoreService()
        let mockv13AccessControlEncryptedSecureStore = MockSecureStoreService()
        sut = EncryptedSecureStoreManager(
            v12EncryptedSecureStore: mockv12AccessControlEncryptedSecureStore,
            v13EncryptedSecureStore: mockv13AccessControlEncryptedSecureStore
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
        #expect(try sut.readItem(OLString.refreshTokenExpiry) == "testRefreshTokenExpiry")
        #expect(try sut.readItem(OLString.persistentSessionID) == "testPersistentSessionID")
        #expect(try sut.readItem(OLString.storedTokens) == "testStoredTokens")
        sut.clearSessionData()
        #expect(throws: SecureStoreError.unableToRetrieveFromUserDefaults) {
            try sut.readItem(OLString.refreshTokenExpiry)
        }
        #expect(throws: SecureStoreError.unableToRetrieveFromUserDefaults) {
            try sut.readItem(OLString.persistentSessionID)
        }
        #expect(throws: SecureStoreError.unableToRetrieveFromUserDefaults) {
            try sut.readItem(OLString.storedTokens)
        }
    }
}
