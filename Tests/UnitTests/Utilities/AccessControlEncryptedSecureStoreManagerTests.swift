@testable import OneLogin
import SecureStore
import Testing

struct AccessControlEncryptedSecureStoreManagerTests: ~Copyable {
    var sut: AccessControlEncryptedSecureStoreManager!
    
    init() throws {
        let mockv12AccessControlEncryptedSecureStore = MockSecureStoreService()
        let mockv13AccessControlEncryptedSecureStore = MockSecureStoreService()
        let mockAnalyticsService = MockAnalyticsService()
        sut = AccessControlEncryptedSecureStoreManager(
            v12AccessControlEncryptedSecureStore: mockv12AccessControlEncryptedSecureStore,
            v13AccessControlEncryptedSecureStore: mockv13AccessControlEncryptedSecureStore,
            analyticsService: mockAnalyticsService
        )
        
        try sut.saveItemTov13RemoveFromv12(
            "testStoredTokens"
        )
    }
    
    deinit {
        sut.clearSessionData()
    }

    @Test("Clear session data deletes the log in tokens")
    func delete() throws {
        #expect(try sut.readItem() == "testStoredTokens")
        sut.clearSessionData()
        #expect(throws: SecureStoreError.unableToRetrieveFromUserDefaults) {
            try sut.readItem()
        }
    }
}
