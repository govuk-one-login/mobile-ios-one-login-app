import Foundation
import SecureStore

public struct StoredTokens: Codable {
    var idToken: String?
    var accessToken: String
}

public protocol TokenStore {
    func fetch() throws -> StoredTokens
    func save(tokens: StoredTokens) throws
    func delete()
}

final class SecureTokenStore: TokenStore {
    private let accessControlEncryptedStore: SecureStorable

    init(accessControlEncryptedStore: SecureStorable) {
        self.accessControlEncryptedStore = accessControlEncryptedStore
    }
    
    func fetch() throws -> StoredTokens {
        let storedTokens = try accessControlEncryptedStore.readItem(itemName: .storedTokens)
        guard let tokensAsData = Data(base64Encoded: storedTokens) else {
                    // Change returned error
                    throw TokenError.bearerNotPresent
                }
        let decodedTokens = try JSONDecoder().decode(StoredTokens.self, from: tokensAsData)
        return decodedTokens
    }
    
    func save(tokens: StoredTokens) throws {
        let tokensAsData = try? JSONEncoder().encode(tokens)
        guard let encodedTokens = tokensAsData?.base64EncodedString() else {
            return
        }
        try accessControlEncryptedStore.saveItem(item: encodedTokens, itemName: .storedTokens)
    }

    func delete() {
        accessControlEncryptedStore.deleteItem(itemName: .storedTokens)
    }
}
