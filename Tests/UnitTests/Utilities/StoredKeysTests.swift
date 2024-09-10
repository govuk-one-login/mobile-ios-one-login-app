import Foundation
@testable import OneLogin
import XCTest

final class StoredKeysTests: XCTestCase {
    private var sut: StoredKeyService!
    private var accessControlEncryptedStore: MockSecureStoreService!

    override func setUp() {
        super.setUp()
        
        accessControlEncryptedStore = MockSecureStoreService()
        sut = StoredKeyService(accessControlEncryptedStore: accessControlEncryptedStore)
    }

    override func tearDown() {
        sut = nil
        accessControlEncryptedStore = nil

        super.tearDown()
    }
}

extension StoredKeysTests {
    func test_canFetchStoredKeys() throws {
        let keysToSave = StoredKeys(idToken: "idToken", accessToken: "accessToken")
        let data = try JSONEncoder().encode(keysToSave).base64EncodedString()
        try sut.saveStoredKeys(keys: keysToSave)
        let storedKeys = try sut.fetchStoredKeys()
        XCTAssertEqual(storedKeys.accessToken, keysToSave.accessToken)
        XCTAssertEqual(storedKeys.idToken, keysToSave.idToken)

    }

    func test_canSaveKeys() throws {
        let keys = StoredKeys(idToken: "idToken", accessToken: "accessToken")
        let data = try JSONEncoder().encode(keys).base64EncodedString()
        try sut.saveStoredKeys(keys: keys)
        XCTAssertEqual(accessControlEncryptedStore.savedItems, [.storedTokens: data])
    }
}
