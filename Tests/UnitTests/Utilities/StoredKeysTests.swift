import Foundation
@testable import OneLogin
import XCTest

final class StoredKeysTests: XCTestCase {
    private var sut: SecureTokenStore!
    private var accessControlEncryptedStore: MockSecureStoreService!

    override func setUp() {
        super.setUp()
        
        accessControlEncryptedStore = MockSecureStoreService()
        sut = SecureTokenStore(accessControlEncryptedStore: accessControlEncryptedStore)
    }

    override func tearDown() {
        sut = nil
        accessControlEncryptedStore = nil

        super.tearDown()
    }
}

extension StoredKeysTests {
    func test_canFetchStoredKeys() throws {
        let keysToSave = StoredTokens(idToken: "idToken", accessToken: "accessToken")
        _ = try JSONEncoder().encode(keysToSave).base64EncodedString()
        try sut.save(tokens: keysToSave)
        let storedKeys = try sut.fetch()
        XCTAssertEqual(storedKeys.accessToken, keysToSave.accessToken)
        XCTAssertEqual(storedKeys.idToken, keysToSave.idToken)
    }

    func test_canSaveKeys() throws {
        let keys = StoredTokens(idToken: "idToken", accessToken: "accessToken")
        let data = try JSONEncoder().encode(keys).base64EncodedString()
        try sut.save(tokens: keys)
        XCTAssertEqual(accessControlEncryptedStore.savedItems, [.storedTokens: data])
    }
}
