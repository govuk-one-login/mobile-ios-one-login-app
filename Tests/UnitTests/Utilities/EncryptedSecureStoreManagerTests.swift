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

    @Test
    func first() throws {
        try mockv12EncryptedSecureStore.saveItem(
            item: "testV12Item",
            itemName: OLString.persistentSessionID
        )
        #expect(try sut.checkItemExists(OLString.persistentSessionID))
    }
    
    @Test
    func second() throws {
        try mockv13EncryptedSecureStore.saveItem(
            item: "testV13Item",
            itemName: OLString.persistentSessionID
        )
        #expect(try sut.checkItemExists(OLString.persistentSessionID))
    }
    
    @Test
    func third() throws {
        try mockv12EncryptedSecureStore.saveItem(
            item: "testItem",
            itemName: OLString.persistentSessionID
        )
        try sut.saveItemTov13RemoveFromv12("testItem", itemName: OLString.persistentSessionID)
        
        #expect(mockv13EncryptedSecureStore.savedItems == [OLString.persistentSessionID: "testItem"])
    }
    
    @Test
    func fourth() throws {
        try mockv12EncryptedSecureStore.saveItem(
            item: "testItem",
            itemName: OLString.persistentSessionID
        )
        let item = try sut.readItem(OLString.persistentSessionID)
        
        #expect(mockv13EncryptedSecureStore.savedItems == [OLString.persistentSessionID: "testItem"])
        #expect(mockAnalyticsService.crashesLogged.count == 1)
        #expect(item == "testItem")
    }
    
    @Test
    func fifth() throws {
        try mockv13EncryptedSecureStore.saveItem(
            item: "testItem",
            itemName: OLString.persistentSessionID
        )
        let item = try sut.readItem(OLString.persistentSessionID)
        
        #expect(item == "testItem")
    }
    
    @Test
    func sixth() throws {
        #expect(throws: SecureStoreError.unableToRetrieveFromUserDefaults) {
            try sut.readItem(OLString.persistentSessionID)
        }
    }
    
    @Test
    func seventh() throws {
        try mockv12EncryptedSecureStore.saveItem(
            item: "testV12Item",
            itemName: OLString.persistentSessionID
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
    
    @Test
    func eighth() throws {
        try mockv12EncryptedSecureStore.saveItem(
            item: "testV12Item",
            itemName: OLString.persistentSessionID
        )
        try mockv13EncryptedSecureStore.saveItem(
            item: "testV13Item",
            itemName: OLString.persistentSessionID
        )
        sut.clearSessionData()
        
        #expect(throws: SecureStoreError.unableToRetrieveFromUserDefaults) {
            try sut.readItem(OLString.persistentSessionID)
        }
    }
}
