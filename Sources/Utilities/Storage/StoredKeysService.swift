import Foundation
import SecureStore

public struct StoredTokens: Codable {
    var idToken: String
    var accessToken: String
}

public protocol StoredKeyServicing {
    func fetchStoredKeys() throws -> StoredTokens
    func saveStoredKeys(keys: StoredTokens) throws
}

final class StoredKeyService: StoredKeyServicing {
    private let accessControlEncryptedStore: SecureStorable

    init(accessControlEncryptedStore: SecureStorable) {
        self.accessControlEncryptedStore = accessControlEncryptedStore
    }
    
    func fetchStoredKeys() throws -> StoredTokens {
        let storedTokens = try accessControlEncryptedStore.readItem(itemName: .storedTokens)
        guard let tokensAsData = Data(base64Encoded: storedTokens) else {
                    // Change returned error
                    throw TokenError.bearerNotPresent
                }
        let decodedTokens = try JSONDecoder().decode(StoredTokens.self, from: tokensAsData)
        return decodedTokens
    }
    
    func saveStoredKeys(keys: StoredTokens) throws {
        let tokensAsData = try? JSONEncoder().encode(keys)
        guard let encodedTokens = tokensAsData?.base64EncodedString() else {
            return
        }
        try accessControlEncryptedStore.saveItem(item: encodedTokens, itemName: .storedTokens)
    }
}
