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

    @Test("check that the item exists in v12 store")
    func checkItemExistsInv12() throws {
        try mockv12AccessControlEncryptedSecureStore.saveItem(
            item: "testV12Item",
            itemName: OLString.storedTokens
        )
        #expect(try sut.checkItemExists())
    }
    
    @Test("check that the item exists in v13 store")
    func checkItemExistsInv13() throws {
        try mockv13AccessControlEncryptedSecureStore.saveItem(
            item: "testV13Item",
            itemName: OLString.storedTokens
        )
        #expect(try sut.checkItemExists())
    }
    
    @Test("check item is saved in v13 and removed from v12")
    func saveItemTov13RemoveFromv12() throws {
        try mockv12AccessControlEncryptedSecureStore.saveItem(
            item: "testItem",
            itemName: OLString.storedTokens
        )
        try sut.saveItemTov13RemoveFromv12("testItem")
        
        #expect(mockv13AccessControlEncryptedSecureStore.savedItems == [OLString.storedTokens: "testItem"])
        #expect(mockv12AccessControlEncryptedSecureStore.savedItems.isEmpty)
    }
    
    @Test("read item from the v12 secure store, save it in v13 secure store, log a crash, remove from v12 store and then return value")
    func readItemv12() throws {
        try mockv12AccessControlEncryptedSecureStore.saveItem(
            item: "testItem",
            itemName: OLString.storedTokens
        )
        let item = try sut.readItem()
        
        #expect(mockv13AccessControlEncryptedSecureStore.savedItems == [OLString.storedTokens: "testItem"])
        #expect(mockAnalyticsService.crashesLogged.count == 1)
        #expect(mockv12AccessControlEncryptedSecureStore.savedItems.isEmpty)
        #expect(item == "testItem")
    }
    
    @Test("read item from v13 if there is no item in v12")
    func readItemv13() throws {
        try mockv13AccessControlEncryptedSecureStore.saveItem(
            item: "testItem",
            itemName: OLString.storedTokens
        )
        let item = try sut.readItem()
        
        #expect(item == "testItem")
    }
    
    @Test("throw error from read item if the value does not exist in either store")
    func readItemNeitherStore() throws {
        #expect(throws: SecureStoreError.unableToRetrieveFromUserDefaults) {
            try sut.readItem()
        }
    }
    
    @Test("ensure items are deleted from both stores")
    func deleteItem() throws {
        try mockv12AccessControlEncryptedSecureStore.saveItem(
            item: "testV12Item",
            itemName: OLString.storedTokens
        )
        try mockv13AccessControlEncryptedSecureStore.saveItem(
            item: "testV13Item",
            itemName: OLString.storedTokens
        )
        sut.deleteItem()
        
        #expect(throws: SecureStoreError.unableToRetrieveFromUserDefaults) {
            try sut.readItem()
        }
    }
    
    @Test("clearSessionData deletes items from both stores")
    func clearSessionData() throws {
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
