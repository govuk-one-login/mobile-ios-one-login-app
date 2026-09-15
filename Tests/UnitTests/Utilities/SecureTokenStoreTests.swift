import Foundation
@testable import OneLogin
import XCTest

final class SecureTokenStoreTests: XCTestCase {
    private var mockAccessControlEncryptedSecureStoreMigrator: MockSecureStoreService!
    private var sut: SecureTokenStore!

    override func setUp() {
        super.setUp()
        
        mockAccessControlEncryptedSecureStoreMigrator = MockSecureStoreService()
        sut = SecureTokenStore(accessControlEncryptedStore: mockAccessControlEncryptedSecureStoreMigrator)
    }

    override func tearDown() {
        mockAccessControlEncryptedSecureStoreMigrator = nil
        sut = nil

        super.tearDown()
    }
}

extension SecureTokenStoreTests {
    func test_hasLoginTokens() throws {
        try mockAccessControlEncryptedSecureStoreMigrator.saveItem(
            item: "storedTokens",
            itemName: OLString.storedTokens
        )
        XCTAssertTrue(sut.hasLoginTokens)
    }
    
    func test_doesNotHaveLoginTokens() async throws {
        try await mockAccessControlEncryptedSecureStoreMigrator.clearSessionData()
        XCTAssertFalse(sut.hasLoginTokens)
    }
    
    func test_canFetchStoredTokens() throws {
        let tokensToSave = StoredTokens(
            idToken: "idToken",
            refreshToken: "refreshToken",
            accessToken: "accessToken",
            accessTokenExpiry: Date()
        )
        
        try sut.save(tokens: tokensToSave)
        let storedTokens = try sut.fetch()
        XCTAssertEqual(storedTokens.accessToken, tokensToSave.accessToken)
        XCTAssertEqual(storedTokens.idToken, tokensToSave.idToken)
    }

    func test_fetchThrowsErrorIfTokensHaveIncorrectFormat() throws {
        try mockAccessControlEncryptedSecureStoreMigrator.saveItem(item: "normal string", itemName: OLString.storedTokens)
        
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
            accessToken: "accessToken",
            accessTokenExpiry: Date()
        )
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .sortedKeys
        let tokensAsData = try jsonEncoder.encode(tokensToSave).base64EncodedString()
        try sut.save(tokens: tokensToSave)
        XCTAssertEqual(mockAccessControlEncryptedSecureStoreMigrator.savedItems, [OLString.storedTokens: tokensAsData])
    }

    func test_deletesTokens() throws {
        try mockAccessControlEncryptedSecureStoreMigrator.saveItem(item: "tokens", itemName: OLString.storedTokens)
        sut.deleteTokens()
        XCTAssertEqual(mockAccessControlEncryptedSecureStoreMigrator.savedItems, [:])
    }
}
