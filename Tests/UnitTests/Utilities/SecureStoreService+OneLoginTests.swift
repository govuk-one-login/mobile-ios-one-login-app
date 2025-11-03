@testable import OneLogin
import SecureStore
import Testing

struct SecureStoreServiceTests: ~Copyable {
    var sut: SecureStoreService!
    
    init() throws {
        let config = SecureStorageConfiguration(
            id: "testConfig",
            accessControlLevel: .open
        )
        sut = SecureStoreService(configuration: config)
        
        try sut.saveItem(
            item: "testRefreshTokenExpiry",
            itemName: OLString.refreshTokenExpiry
        )
        try sut.saveItem(
            item: "testPersistentSessionID",
            itemName: OLString.persistentSessionID
        )
        try sut.saveItem(
            item: "testStoredTokens",
            itemName: OLString.storedTokens
        )
    }
    
    deinit {
        try? sut.delete()
    }

    @Test
    func delete() throws {
        #expect(try sut.readItem(itemName: OLString.refreshTokenExpiry) == "testRefreshTokenExpiry")
        #expect(try sut.readItem(itemName: OLString.persistentSessionID) == "testPersistentSessionID")
        #expect(try sut.readItem(itemName: OLString.storedTokens) == "testStoredTokens")
        sut.clearSessionData()
        #expect(throws: SecureStoreError.unableToRetrieveFromUserDefaults) {
            try sut.readItem(itemName: OLString.refreshTokenExpiry)
        }
        #expect(throws: SecureStoreError.unableToRetrieveFromUserDefaults) {
            try sut.readItem(itemName: OLString.persistentSessionID)
        }
        #expect(throws: SecureStoreError.unableToRetrieveFromUserDefaults) {
            try sut.readItem(itemName: OLString.storedTokens)
        }
    }
}
