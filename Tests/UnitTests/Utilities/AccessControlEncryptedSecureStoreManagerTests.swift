import Foundation
@testable import OneLogin
import SecureStore
import Testing

struct AccessControlEncryptedSecureStoreManagerTests {
    let mockv12AccessControlEncryptedSecureStore: MockSecureStoreService
    let mockv13AccessControlEncryptedSecureStore: MockSecureStoreService
    let mockAnalyticsService: MockAnalyticsService
    let sut: AccessControlEncryptedSecureStoreManager
    
    init() {
        mockv12AccessControlEncryptedSecureStore = MockSecureStoreService()
        mockv13AccessControlEncryptedSecureStore = MockSecureStoreService()
        mockAnalyticsService = MockAnalyticsService()
        
        self.sut = AccessControlEncryptedSecureStoreManager(
            v12AccessControlEncryptedSecureStore: mockv12AccessControlEncryptedSecureStore,
            v13AccessControlEncryptedSecureStore: mockv13AccessControlEncryptedSecureStore,
            analyticsService: mockAnalyticsService
        )
    }

    @Test
    func first() throws {
        try mockv12AccessControlEncryptedSecureStore.saveItem(
            item: "testV12Item",
            itemName: OLString.storedTokens
        )
        #expect(try sut.checkItemExists())
    }
    
    @Test
    func second() throws {
        try mockv13AccessControlEncryptedSecureStore.saveItem(
            item: "testV13Item",
            itemName: OLString.storedTokens
        )
        #expect(try sut.checkItemExists())
    }
    
    @Test
    func third() throws {
        try mockv12AccessControlEncryptedSecureStore.saveItem(
            item: "testItem",
            itemName: OLString.storedTokens
        )
        try sut.saveItemTov13RemoveFromv12("testItem")
        
        #expect(mockv13AccessControlEncryptedSecureStore.savedItems == [OLString.storedTokens: "testItem"])
    }
    
    @Test
    func fourth() throws {
        try mockv12AccessControlEncryptedSecureStore.saveItem(
            item: "testItem",
            itemName: OLString.storedTokens
        )
        let item = try sut.readItem()
        
        #expect(mockv13AccessControlEncryptedSecureStore.savedItems == [OLString.storedTokens: "testItem"])
        #expect(mockAnalyticsService.crashesLogged.count == 1)
        #expect(item == "testItem")
    }
    
    @Test
    func fifth() throws {
        try mockv13AccessControlEncryptedSecureStore.saveItem(
            item: "testItem",
            itemName: OLString.storedTokens
        )
        let item = try sut.readItem()
        
        #expect(item == "testItem")
    }
    
    @Test
    func sixth() throws {
        #expect(throws: SecureStoreError.unableToRetrieveFromUserDefaults) {
            try sut.readItem()
        }
    }
    
    @Test
    func seventh() throws {
        try mockv12AccessControlEncryptedSecureStore.saveItem(
            item: "testV12Item",
            itemName: OLString.storedTokens
        )
        try mockv13AccessControlEncryptedSecureStore.saveItem(
            item: "testV13Item",
            itemName: OLString.storedTokens
        )
        sut.deleteItem(OLString.storedTokens)
        
        #expect(throws: SecureStoreError.unableToRetrieveFromUserDefaults) {
            try sut.readItem()
        }
    }
    
    @Test
    func eighth() throws {
        try mockv12AccessControlEncryptedSecureStore.saveItem(
            item: "testV12Item",
            itemName: OLString.storedTokens
        )
        try mockv13AccessControlEncryptedSecureStore.saveItem(
            item: "testV13Item",
            itemName: OLString.storedTokens
        )
        sut.clearSessionData()
        
        #expect(throws: SecureStoreError.unableToRetrieveFromUserDefaults) {
            try sut.readItem()
        }
    }
}
