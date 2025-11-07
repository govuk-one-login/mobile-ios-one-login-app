import Foundation
@testable import OneLogin
import XCTest

final class SecureTokenStoreTests: XCTestCase {
    private var accessControlEncryptedSecureStoreManager: MockSecureStoreManager!
    private var sut: SecureTokenStore!

    override func setUp() {
        super.setUp()
        
        accessControlEncryptedSecureStoreManager = MockSecureStoreManager()
        sut = SecureTokenStore(accessControlEncryptedSecureStoreManager: accessControlEncryptedSecureStoreManager)
    }

    override func tearDown() {
        accessControlEncryptedSecureStoreManager = nil
        sut = nil

        super.tearDown()
    }
}

extension SecureTokenStoreTests {
    func test_hasLoginTokens() throws {
        try accessControlEncryptedSecureStoreManager.saveItem(
            item: "storedTokens",
            itemName: OLString.storedTokens
        )
        XCTAssertTrue(sut.hasLoginTokens)
    }
    
    func test_doesNotHaveLoginTokens() throws {
        accessControlEncryptedSecureStoreManager.savedItems = [:]
        XCTAssertFalse(sut.hasLoginTokens)
    }
    
    func test_canFetchStoredTokens() throws {
        let tokensToSave = StoredTokens(
            idToken: "idToken",
            refreshToken: "refreshToken",
            accessToken: "accessToken"
        )
        
        try sut.save(tokens: tokensToSave)
        let storedTokens = try sut.fetch()
        XCTAssertEqual(storedTokens.accessToken, tokensToSave.accessToken)
        XCTAssertEqual(storedTokens.idToken, tokensToSave.idToken)
    }

    func test_fetchThrowsErrorIfTokensHaveIncorrectFormat() throws {
        accessControlEncryptedSecureStoreManager.savedItems = [OLString.storedTokens: "normal string"]
        do {
            _ = try sut.fetch()
            XCTFail("Expected to recieve token error")
        } catch let error as StoredTokenError {
            XCTAssert(error == .unableToDecodeTokens)
        }
    }

    func test_canSaveKeys() throws {
        let tokensToSave = StoredTokens(
            idToken: "idToken",
            refreshToken: "refreshToken",
            accessToken: "accessToken"
        )
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .sortedKeys
        let tokensAsData = try jsonEncoder.encode(tokensToSave).base64EncodedString()
        print(tokensAsData)
        try sut.save(tokens: tokensToSave)
        XCTAssertEqual(accessControlEncryptedSecureStoreManager.savedItems, [OLString.storedTokens: tokensAsData])
    }

    func test_deletesTokens() throws {
        accessControlEncryptedSecureStoreManager.savedItems = [OLString.storedTokens: "tokens"]
        sut.deleteTokens()
        XCTAssertEqual(accessControlEncryptedSecureStoreManager.savedItems, [:])
    }
}
