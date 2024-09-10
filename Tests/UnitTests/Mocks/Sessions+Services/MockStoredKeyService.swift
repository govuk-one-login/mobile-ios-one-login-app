import Foundation
@testable import OneLogin

final class MockSecureTokenStore: TokenStore {
    var mockStoredKeys: StoredTokens?
    var didCallFetch: Bool = false
    var didCallSave: Bool = false
    var didCallDelete: Bool = false

    func fetch() throws -> StoredTokens {
        didCallFetch = true
//      This is force unwrapped, ensure the value is assigned above before calling `fetchStoreKeys` in tests
        return mockStoredKeys!
    }
    
    func save(tokens: StoredTokens) throws {
        didCallSave = true
    }

    func delete() {
        didCallDelete = true
    }
}
