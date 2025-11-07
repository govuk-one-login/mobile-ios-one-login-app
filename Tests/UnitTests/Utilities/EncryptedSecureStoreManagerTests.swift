@testable import OneLogin
import SecureStore
import Testing

struct EncryptedSecureStoreManagerTests: ~Copyable {
    var sut: EncryptedSecureStoreManager!
    
    init() throws {
        let mockv12AccessControlEncryptedSecureStore = MockSecureStoreService()
        let mockv13AccessControlEncryptedSecureStore = MockSecureStoreService()
        let mockAnalyticsService = MockAnalyticsService()
        sut = EncryptedSecureStoreManager(
            v12EncryptedSecureStore: mockv12AccessControlEncryptedSecureStore,
            v13EncryptedSecureStore: mockv13AccessControlEncryptedSecureStore,
            analyticsService: mockAnalyticsService
        )
        
        try sut.saveItemTov13RemoveFromv12(
            "testRefreshTokenExpiry",
            itemName: OLString.refreshTokenExpiry
        )
        try sut.saveItemTov13RemoveFromv12(
            "testPersistentSessionID",
            itemName: OLString.persistentSessionID
        )
        try sut.saveItemTov13RemoveFromv12(
            "testStoredTokens",
            itemName: OLString.storedTokens
        )
    }
    
    deinit {
        sut.clearSessionData()
    }

    @Test("Clear session data deletes the refresh token and persistentSessionID")
    func delete() throws {
        #expect(try sut.readItem(OLString.refreshTokenExpiry) == "testRefreshTokenExpiry")
        #expect(try sut.readItem(OLString.persistentSessionID) == "testPersistentSessionID")
        sut.clearSessionData()
        #expect(throws: SecureStoreError.unableToRetrieveFromUserDefaults) {
            try sut.readItem(OLString.refreshTokenExpiry)
        }
        #expect(throws: SecureStoreError.unableToRetrieveFromUserDefaults) {
            try sut.readItem(OLString.persistentSessionID)
        }
    }
}
