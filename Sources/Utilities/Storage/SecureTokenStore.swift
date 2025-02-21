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
    var hasLoginTokens: Bool { get }
    func fetch() throws -> StoredTokens
    func save(tokens: StoredTokens) throws
    func deleteTokens()
}

final class SecureTokenStore: TokenStore {
    private let accessControlEncryptedStore: SecureStorable

    init(accessControlEncryptedStore: SecureStorable) {
        self.accessControlEncryptedStore = accessControlEncryptedStore
    }
    
    var hasLoginTokens: Bool {
        accessControlEncryptedStore.checkItemExists(itemName: OLString.storedTokens)
    }
    
    func fetch() throws -> StoredTokens {
        let storedTokens = try accessControlEncryptedStore.readItem(itemName: OLString.storedTokens)
        guard let tokensAsData = Data(base64Encoded: storedTokens) else {
            throw StoredTokenError.unableToDecodeTokens
        }
        let decodedTokens = try JSONDecoder().decode(StoredTokens.self, from: tokensAsData)
        return decodedTokens
    }
    
    func save(tokens: StoredTokens) throws {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .sortedKeys
        let tokensAsData = try jsonEncoder.encode(tokens)
        let encodedTokens = tokensAsData.base64EncodedString()
        try accessControlEncryptedStore.saveItem(item: encodedTokens, itemName: OLString.storedTokens)
    }

    func deleteTokens() {
        accessControlEncryptedStore.deleteItem(itemName: OLString.storedTokens)
    }
}
