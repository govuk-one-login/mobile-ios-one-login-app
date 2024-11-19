import Foundation
import SecureStore

enum StoredTokenError: Error {
    case unableToDecodeTokens
}

public struct StoredTokens: Codable {
    let idToken: String?
    let accessToken: String
}

public protocol TokenStore {
    func fetch() throws -> StoredTokens
    func save(tokens: StoredTokens) throws
    func delete()
}

final class SecureTokenStore: TokenStore {
    private let jsonEncoder: JSONEncoder
    private let accessControlEncryptedStore: SecureStorable

    init(accessControlEncryptedStore: SecureStorable) {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .sortedKeys
        self.jsonEncoder = jsonEncoder
        self.accessControlEncryptedStore = accessControlEncryptedStore
    }
    
    func fetch() throws -> StoredTokens {
        let storedTokens = try accessControlEncryptedStore.readItem(itemName: .storedTokens)
        guard let tokensAsData = Data(base64Encoded: storedTokens) else {
            throw StoredTokenError.unableToDecodeTokens
        }
        let decodedTokens = try JSONDecoder().decode(StoredTokens.self, from: tokensAsData)
        return decodedTokens
    }
    
    func save(tokens: StoredTokens) throws {
        let tokensAsData = try jsonEncoder.encode(tokens)
        let encodedTokens = tokensAsData.base64EncodedString()
        try accessControlEncryptedStore.saveItem(item: encodedTokens, itemName: .storedTokens)
    }

    func delete() {
        accessControlEncryptedStore.deleteItem(itemName: .storedTokens)
    }
}
