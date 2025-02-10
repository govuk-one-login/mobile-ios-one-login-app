import Foundation
@testable import OneLogin

final class MockSecureTokenStore: TokenStore {
    var mockStoredTokens: StoredTokens?
    var didCallFetch: Bool = false
    var didCallSave: Bool = false
    var didCallDeleteTokens: Bool = false

    func fetch() throws -> StoredTokens {
        didCallFetch = true
//      This is force unwrapped, ensure the value is assigned above before calling `fetchStoreKeys` in tests
        return mockStoredTokens!
    }
    
    func save(tokens: StoredTokens) throws {
        didCallSave = true
    }

    func deleteTokens() {
        didCallDeleteTokens = true
    }
}
