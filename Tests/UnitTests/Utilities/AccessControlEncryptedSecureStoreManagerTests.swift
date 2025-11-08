import Foundation
@testable import OneLogin
import SecureStore
import Testing

struct AccessControlEncryptedSecureStoreManagerTests {
    let mockV12AccessControlEncryptedSecureStore: MockSecureStoreService
    let mockV13AccessControlEncryptedSecureStore: MockSecureStoreService
    let mockMigrationStore: MockDefaultsStore
    let mockAnalyticsService: MockAnalyticsService
    let sut: AccessControlEncryptedSecureStoreMigrator
    
    init() {
        mockV12AccessControlEncryptedSecureStore = MockSecureStoreService()
        mockV13AccessControlEncryptedSecureStore = MockSecureStoreService()
        mockMigrationStore = MockDefaultsStore()
        mockAnalyticsService = MockAnalyticsService()
        
        self.sut = AccessControlEncryptedSecureStoreMigrator(
            v12AccessControlEncryptedSecureStore: mockV12AccessControlEncryptedSecureStore,
            v13AccessControlEncryptedSecureStore: mockV13AccessControlEncryptedSecureStore,
            migrationStore: mockMigrationStore,
            analyticsService: mockAnalyticsService
        )
    }

    @Test("check that v12 store `itemExists` returns true when the item exists")
    func checkItemExistsInV12() throws {
        try mockV12AccessControlEncryptedSecureStore.saveItem(
            item: "testV12Item",
            itemName: OLString.storedTokens
        )
        #expect(sut.checkItemExists())
    }
    
    @Test("check that v13 store `itemExists` returns true when the item exists")
    func checkItemExistsInV13() throws {
        try mockV13AccessControlEncryptedSecureStore.saveItem(
            item: "testV13Item",
            itemName: OLString.storedTokens
        )
        #expect(sut.checkItemExists())
    }
    
    @Test("check data item is successfully migrated from v12 to v13")
    func saveItemToV13OverwritesV12() throws {
        try mockV12AccessControlEncryptedSecureStore.saveItem(
            item: "testItem",
            itemName: OLString.storedTokens
        )
        try sut.saveItem(item: "testItem")
        
        #expect(mockV13AccessControlEncryptedSecureStore.savedItems == [OLString.storedTokens: "testItem"])
        #expect(mockMigrationStore.bool(forKey: OLString.migratedAccessControlEncryptedStoreToV13))
    }
    
    @Test("read item migrates data to the v13 store if required")
    func readItemV12MigratesToV13() throws {
        try mockV12AccessControlEncryptedSecureStore.saveItem(
            item: "testItem",
            itemName: OLString.storedTokens
        )
        let item = try sut.readItem()
        
        #expect(mockV13AccessControlEncryptedSecureStore.savedItems == [OLString.storedTokens: "testItem"])
        #expect(item == "testItem")
    }
    
    @Test("read item logs to crashlytics if a migration is required")
    func readItemV12LogsCrash() throws {
        try mockV12AccessControlEncryptedSecureStore.saveItem(
            item: "testItem",
            itemName: OLString.storedTokens
        )
        _ = try sut.readItem()
        
        #expect(mockAnalyticsService.crashesLogged.count == 1)
        #expect(mockAnalyticsService.crashesLogged.first == SecureStoreMigrationError.migratedFromv12Tov13 as NSError)
    }
    
    @Test("read item returns the v13 value if no v12 value exists")
    func readItemV13() throws {
        try mockV13AccessControlEncryptedSecureStore.saveItem(
            item: "testItem",
            itemName: OLString.storedTokens
        )
        let item = try sut.readItem()
        
        #expect(item == "testItem")
    }
    
    @Test("read item returns the v13 if value has been migrated")
    func readItemV13IfMigrated() throws {
        mockMigrationStore.set(
            true,
            forKey: OLString.migratedAccessControlEncryptedStoreToV13
        )
        try mockV13AccessControlEncryptedSecureStore.saveItem(
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
        try mockV12AccessControlEncryptedSecureStore.saveItem(
            item: "testV12Item",
            itemName: OLString.storedTokens
        )
        try mockV13AccessControlEncryptedSecureStore.saveItem(
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
        try mockV12AccessControlEncryptedSecureStore.saveItem(
            item: "testV12Item",
            itemName: OLString.storedTokens
        )
        try mockV13AccessControlEncryptedSecureStore.saveItem(
            item: "testV13Item",
            itemName: OLString.storedTokens
        )
        sut.clearSessionData()
        
        #expect(throws: SecureStoreError.unableToRetrieveFromUserDefaults) {
            try sut.readItem()
        }
    }
}
