@testable import OneLogin
import SecureStore
import Testing

struct SecureStoreServiceTests: ~Copyable {
    var sut: SecureStoreServiceV2!
    
    init() throws {
        let config = SecureStorageConfiguration(
            id: "testConfig",
            accessControlLevel: .open
        )
        sut = SecureStoreServiceV2(configuration: config)
        
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

    @Test("Clear session data deletes the refresh token, persistentSessionID and tokens")
    func delete() throws {
        #expect(try sut.readItem(itemName: OLString.refreshTokenExpiry) == "testRefreshTokenExpiry")
        #expect(try sut.readItem(itemName: OLString.persistentSessionID) == "testPersistentSessionID")
        #expect(try sut.readItem(itemName: OLString.storedTokens) == "testStoredTokens")
        sut.clearSessionData()
        #expect(throws: SecureStoreErrorV2(.unableToRetrieveFromUserDefaults)) {
            try sut.readItem(itemName: OLString.refreshTokenExpiry)
        }
        #expect(throws: SecureStoreErrorV2(.unableToRetrieveFromUserDefaults)) {
            try sut.readItem(itemName: OLString.persistentSessionID)
        }
        #expect(throws: SecureStoreErrorV2(.unableToRetrieveFromUserDefaults)) {
            try sut.readItem(itemName: OLString.storedTokens)
        }
    }
}
