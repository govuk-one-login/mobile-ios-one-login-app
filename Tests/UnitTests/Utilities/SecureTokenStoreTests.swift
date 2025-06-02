import Foundation
@testable import OneLogin
import XCTest

final class SecureTokenStoreTests: XCTestCase {
    private var accessControlEncryptedStore: MockSecureStoreService!
    private var sut: SecureTokenStore!

    override func setUp() {
        super.setUp()
        
        accessControlEncryptedStore = MockSecureStoreService()
        sut = SecureTokenStore(accessControlEncryptedStore: accessControlEncryptedStore)
    }

    override func tearDown() {
        accessControlEncryptedStore = nil
        sut = nil

        super.tearDown()
    }
}

extension SecureTokenStoreTests {
    func test_hasLoginTokens() throws {
        try accessControlEncryptedStore.saveItem(item: "storedTokens", itemName: OLString.storedTokens)
        XCTAssertTrue(sut.hasLoginTokens)
    }
    
    func test_doesNotHaveLoginTokens() throws {
        accessControlEncryptedStore.savedItems = [:]
        XCTAssertFalse(sut.hasLoginTokens)
    }
    
    func test_canFetchStoredTokens() throws {
        let tokensToSave = StoredTokens(idToken: "idToken", accessToken: "accessToken")
        try sut.save(tokens: tokensToSave)
        let storedTokens = try sut.fetch()
        XCTAssertEqual(storedTokens.accessToken, tokensToSave.accessToken)
        XCTAssertEqual(storedTokens.idToken, tokensToSave.idToken)
    }

    func test_fetchThrowsErrorIfTokensHaveIncorrectFormat() throws {
        accessControlEncryptedStore.savedItems = [OLString.storedTokens: "normal string"]
        do {
            _ = try sut.fetch()
            XCTFail("Expected to recieve token error")
        } catch let error as StoredTokenError {
            XCTAssert(error == .unableToDecodeTokens)
        }
    }

    func test_canSaveKeys() throws {
        let tokens = StoredTokens(idToken: "idToken", accessToken: "accessToken")
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .sortedKeys
        let tokensAsData = try jsonEncoder.encode(tokens).base64EncodedString()
        print(tokensAsData)
        try sut.save(tokens: tokens)
        XCTAssertEqual(accessControlEncryptedStore.savedItems, [OLString.storedTokens: tokensAsData])
    }

    func test_deletesTokens() throws {
        accessControlEncryptedStore.savedItems = [OLString.storedTokens: "tokens"]
        sut.deleteTokens()
        XCTAssertEqual(accessControlEncryptedStore.savedItems, [:])
    }
}
