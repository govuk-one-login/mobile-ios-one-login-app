import Foundation
import SecureStore

enum StoredTokenError: Error {
    case unableToDecodeTokens
}

public struct StoredTokens: Codable {
    let idToken: String?
    let refreshToken: String?
    let accessToken: String
}

public protocol TokenStore {
    var hasLoginTokens: Bool { get }
    func fetch() throws -> StoredTokens
    func save(tokens: StoredTokens) throws
    func deleteTokens()
}

final class SecureTokenStore: TokenStore {
    private let accessControlEncryptedSecureStoreManager: SecureStoreMigrationManaging
    
    init(accessControlEncryptedSecureStoreManager: SecureStoreMigrationManaging) {
        self.accessControlEncryptedSecureStoreManager = accessControlEncryptedSecureStoreManager
    }
    
    var hasLoginTokens: Bool {
        accessControlEncryptedSecureStoreManager.checkItemExists(OLString.storedTokens)
    }
    
    func fetch() throws -> StoredTokens {
        let storedTokens = try accessControlEncryptedSecureStoreManager.readItem(OLString.storedTokens)
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
        try accessControlEncryptedSecureStoreManager.saveItemToNewStoreRemoveFromOldStore(
            encodedTokens,
            itemName: OLString.storedTokens
        )
    }
    
    func deleteTokens() {
        accessControlEncryptedSecureStoreManager.deleteItem(OLString.storedTokens)
    }
}
