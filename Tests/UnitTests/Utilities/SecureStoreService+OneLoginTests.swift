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
        
        try sut.saveItemV2(
            item: "testRefreshTokenExpiry",
            itemName: OLString.refreshTokenExpiry
        )
        try sut.saveItemV2(
            item: "testPersistentSessionID",
            itemName: OLString.persistentSessionID
        )
        try sut.saveItemV2(
            item: "testStoredTokens",
            itemName: OLString.storedTokens
        )
    }
    
    deinit {
        try? sut.delete()
    }

    @Test("Clear session data deletes the refresh token, persistentSessionID and tokens")
    func delete() throws {
        #expect(try sut.readItemV2(itemName: OLString.refreshTokenExpiry) == "testRefreshTokenExpiry")
        #expect(try sut.readItemV2(itemName: OLString.persistentSessionID) == "testPersistentSessionID")
        #expect(try sut.readItemV2(itemName: OLString.storedTokens) == "testStoredTokens")
        sut.clearSessionData()
        #expect(throws: SecureStoreErrorV2(.unableToRetrieveFromUserDefaults)) {
            try sut.readItemV2(itemName: OLString.refreshTokenExpiry)
        }
        #expect(throws: SecureStoreErrorV2(.unableToRetrieveFromUserDefaults)) {
            try sut.readItemV2(itemName: OLString.persistentSessionID)
        }
        #expect(throws: SecureStoreErrorV2(.unableToRetrieveFromUserDefaults)) {
            try sut.readItemV2(itemName: OLString.storedTokens)
        }
    }
}
