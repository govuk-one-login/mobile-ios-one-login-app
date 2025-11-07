import Foundation
@testable import OneLogin
import SecureStore
import Testing

struct EncryptedSecureStoreManagerTests {
    let mockv12EncryptedSecureStore: MockSecureStoreService
    let mockv13EncryptedSecureStore: MockSecureStoreService
    let mockAnalyticsService: MockAnalyticsService
    let sut: EncryptedSecureStoreManager
    
    init() {
        mockv12EncryptedSecureStore = MockSecureStoreService()
        mockv13EncryptedSecureStore = MockSecureStoreService()
        mockAnalyticsService = MockAnalyticsService()
        
        self.sut = EncryptedSecureStoreManager(
            v12EncryptedSecureStore: mockv12EncryptedSecureStore,
            v13EncryptedSecureStore: mockv13EncryptedSecureStore,
            analyticsService: mockAnalyticsService
        )
    }

    @Test("check that v12 store `itemExists` returns true when the item exists")
    func checkItemExistsInv12() throws {
        try mockv12EncryptedSecureStore.saveItem(
            item: "testV12Item",
            itemName: OLString.persistentSessionID
        )
        #expect(try sut.checkItemExists(OLString.persistentSessionID))
    }
    
    @Test("check that v13 store `itemExists` returns true when the item exists")
    func checkItemExistsInv13() throws {
        try mockv13EncryptedSecureStore.saveItem(
            item: "testV13Item",
            itemName: OLString.persistentSessionID
        )
        #expect(try sut.checkItemExists(OLString.persistentSessionID))
    }
    
    @Test("check data item is successfully migrated from v12 to v13")
    func saveItemTov13RemoveFromv12() throws {
        try mockv12EncryptedSecureStore.saveItem(
            item: "testItem",
            itemName: OLString.persistentSessionID
        )
        try sut.saveItemTov13RemoveFromv12("testItem", itemName: OLString.persistentSessionID)
        
        #expect(mockv13EncryptedSecureStore.savedItems == [OLString.persistentSessionID: "testItem"])
        #expect(mockv12EncryptedSecureStore.savedItems.isEmpty)
    }
    
    @Test("read item from the v12 secure store, save it in v13 secure store, log a crash, remove from v12 store and then return value")
    func readItemv12() throws {
        try mockv12EncryptedSecureStore.saveItem(
            item: "testItem",
            itemName: OLString.persistentSessionID
        )
        let item = try sut.readItem(OLString.persistentSessionID)
        
        #expect(mockv13EncryptedSecureStore.savedItems == [OLString.persistentSessionID: "testItem"])
        #expect(mockAnalyticsService.crashesLogged.count == 1)
        #expect(item == "testItem")
    }
    
    @Test("read item from v13 if there is no item in v12")
    func readItemv13() throws {
        try mockv13EncryptedSecureStore.saveItem(
            item: "testItem",
            itemName: OLString.persistentSessionID
        )
        let item = try sut.readItem(OLString.persistentSessionID)
        
        #expect(item == "testItem")
    }
    
    @Test("throw error from read item if the value does not exist in either store")
    func readItemNeitherStore() throws {
        #expect(throws: SecureStoreError.unableToRetrieveFromUserDefaults) {
            try sut.readItem(OLString.persistentSessionID)
        }
    }
    
    @Test("ensure items are deleted from both stores")
    func deleteItem() throws {
        try mockv13EncryptedSecureStore.saveItem(
            item: "testV13Item",
            itemName: OLString.refreshTokenExpiry
        )
        try mockv13EncryptedSecureStore.saveItem(
            item: "testV13Item",
            itemName: OLString.persistentSessionID
        )
        sut.deleteItem(OLString.persistentSessionID)
        
        #expect(throws: SecureStoreError.unableToRetrieveFromUserDefaults) {
            try sut.readItem(OLString.persistentSessionID)
        }
    }
    
    @Test("clearSessionData deletes items from both stores")
    func clearSessionData() throws {
        try mockv13EncryptedSecureStore.saveItem(
            item: "testV13Item",
            itemName: OLString.refreshTokenExpiry
        )
        try mockv12EncryptedSecureStore.saveItem(
            item: "testV12Item",
            itemName: OLString.persistentSessionID
        )
        sut.clearSessionData()
        
        #expect(throws: SecureStoreError.unableToRetrieveFromUserDefaults) {
            try sut.readItem(OLString.persistentSessionID)
        }
    }
}
