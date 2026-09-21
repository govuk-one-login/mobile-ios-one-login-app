import Foundation
@testable import OneLogin
import SecureStore

final class MockSecureTokenStore: TokenStore {
    var mockStoredTokens: StoredTokens?
    var didCallFetch: Bool = false
    var didCallSave: Bool = false
    var didCallSaveUsingEncryptor: Bool = false
    var didCallDeleteTokens: Bool = false
    
    var hasLoginTokens: Bool = false

    func fetch() throws -> StoredTokens {
        didCallFetch = true
//      This is force unwrapped, ensure the value is assigned above before calling `fetchStoreKeys` in tests
        return mockStoredTokens!
    }

    func save(using encryptor: Encryptor, tokens: StoredTokens) throws {
        didCallSaveUsingEncryptor = true
    }

    func save(tokens: StoredTokens) throws {
        didCallSave = true
    }

    func deleteTokens() {
        didCallDeleteTokens = true
    }
}
