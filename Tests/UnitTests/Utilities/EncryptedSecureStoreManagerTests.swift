import Foundation
@testable import OneLogin
import SecureStore
import Testing

struct EncryptedSecureStoreManagerTests {
    let mockV12EncryptedSecureStore: MockSecureStoreService
    let mockV13EncryptedSecureStore: MockSecureStoreService
    let mockMigrationStore: MockDefaultsStore
    let mockAnalyticsService: MockAnalyticsService
    let sut: EncryptedSecureStoreMigrator
    
    init() {
        mockV12EncryptedSecureStore = MockSecureStoreService()
        mockV13EncryptedSecureStore = MockSecureStoreService()
        mockMigrationStore = MockDefaultsStore()
        mockAnalyticsService = MockAnalyticsService()
        
        self.sut = EncryptedSecureStoreMigrator(
            v12EncryptedSecureStore: mockV12EncryptedSecureStore,
            v13EncryptedSecureStore: mockV13EncryptedSecureStore,
            migrationStore: mockMigrationStore,
            analyticsService: mockAnalyticsService
        )
    }

    @Test("check that v12 store `itemExists` returns true when the item exists")
    func checkItemExistsInV12() throws {
        try mockV12EncryptedSecureStore.saveItem(
            item: "testV12Item",
            itemName: OLString.persistentSessionID
        )
        #expect(sut.checkItemExists(itemName: OLString.persistentSessionID))
    }
    
    @Test("check that v13 store `itemExists` returns true when the item exists")
    func checkItemExistsInV13() throws {
        try mockV13EncryptedSecureStore.saveItem(
            item: "testV13Item",
            itemName: OLString.persistentSessionID
        )
        #expect(sut.checkItemExists(itemName: OLString.persistentSessionID))
    }
    
    @Test("check data item is successfully migrated from v12 to v13")
    func saveItemToV13OverwritesV12() throws {
        try sut.saveItem(
            item: "testItem",
            itemName: OLString.persistentSessionID
        )
        
        #expect(mockV13EncryptedSecureStore.savedItems == [OLString.persistentSessionID: "testItem"])
        #expect(mockMigrationStore.bool(forKey: OLString.migratedEncryptedStoreToV13))
    }
    
    @Test("read item migrates data to the v13 store if required")
    func readItemV12MigratesToV13() throws {
        try mockV12EncryptedSecureStore.saveItem(
            item: "testItem",
            itemName: OLString.persistentSessionID
        )
        let item = try sut.readItem(itemName: OLString.persistentSessionID)
        
        #expect(mockV13EncryptedSecureStore.savedItems == [OLString.persistentSessionID: "testItem"])
        #expect(item == "testItem")
    }
    
    @Test("read item logs to crashlytics if a migration is required")
    func readItemV12LogsCrash() throws {
        try mockV12EncryptedSecureStore.saveItem(
            item: "testItem",
            itemName: OLString.persistentSessionID
        )
        _ = try sut.readItem(itemName: OLString.persistentSessionID)
        
        #expect(mockAnalyticsService.crashesLogged.count == 1)
        #expect(mockAnalyticsService.crashesLogged.first == SecureStoreMigrationError.migratedFromv12Tov13 as NSError)
    }
    
    @Test("read item returns the v13 value if no v12 value exists")
    func readItemV13() throws {
        try mockV13EncryptedSecureStore.saveItem(
            item: "testItem",
            itemName: OLString.persistentSessionID
        )
        let item = try sut.readItem(itemName: OLString.persistentSessionID)
        
        #expect(item == "testItem")
    }
    
    @Test("read item returns the v13 if value has been migrated")
    func readItemV13IfMigrated() throws {
        mockMigrationStore.set(
            true,
            forKey: OLString.migratedEncryptedStoreToV13
        )
        try mockV13EncryptedSecureStore.saveItem(
            item: "testItem",
            itemName: OLString.persistentSessionID
        )
        let item = try sut.readItem(itemName: OLString.persistentSessionID)
        
        #expect(item == "testItem")
    }
    
    @Test("throw error from read item if the value does not exist in either store")
    func readItemNeitherStore() throws {
        #expect(throws: SecureStoreError.unableToRetrieveFromUserDefaults) {
            try sut.readItem(itemName: OLString.persistentSessionID)
        }
    }
    
    @Test("ensure items are deleted from both stores")
    func deleteItem() throws {
        try mockV13EncryptedSecureStore.saveItem(
            item: "testV13Item",
            itemName: OLString.refreshTokenExpiry
        )
        try mockV13EncryptedSecureStore.saveItem(
            item: "testV13Item",
            itemName: OLString.persistentSessionID
        )
        sut.deleteItem(itemName: OLString.persistentSessionID)
        
        #expect(throws: SecureStoreError.unableToRetrieveFromUserDefaults) {
            try sut.readItem(itemName: OLString.persistentSessionID)
        }
    }
    
    @Test("clearSessionData deletes items from both stores")
    func clearSessionData() throws {
        try mockV13EncryptedSecureStore.saveItem(
            item: "testV13Item",
            itemName: OLString.refreshTokenExpiry
        )
        try mockV12EncryptedSecureStore.saveItem(
            item: "testV12Item",
            itemName: OLString.persistentSessionID
        )
        sut.clearSessionData()
        
        #expect(throws: SecureStoreError.unableToRetrieveFromUserDefaults) {
            try sut.readItem(itemName: OLString.persistentSessionID)
        }
    }
}
