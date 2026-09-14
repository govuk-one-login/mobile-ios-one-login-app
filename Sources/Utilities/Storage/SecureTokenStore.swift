import Foundation
import SecureStore

enum StoredTokenError: Error {
    case unableToDecodeTokens
}

public struct StoredTokens: Codable {
    let idToken: String?
    let refreshToken: String?
    let accessToken: String?
    let accessTokenExpiry: Date?
}

public protocol TokenStore {
    var hasLoginTokens: Bool { get }

    func fetch() throws -> StoredTokens
    func save(using encryptor: Encryptor, tokens: StoredTokens) throws
    func save(tokens: StoredTokens) throws
    func deleteTokens()
}

extension StoredTokens {
    public func base64EncodedJSON() throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(self)
        return data.base64EncodedString()
    }
}

final class SecureTokenStore: TokenStore {
    private let accessControlEncryptedStore: EncryptedSecureStorable
    
    init(accessControlEncryptedStore: EncryptedSecureStorable) {
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

    func save(using encryptor: Encryptor, tokens: StoredTokens) throws {
        try accessControlEncryptedStore.save(using: encryptor,
                                             item: try tokens.base64EncodedJSON(),
                                             itemName: OLString.storedTokens)
    }

    func save(tokens: StoredTokens) throws {
        try accessControlEncryptedStore.saveItem(
            item: try tokens.base64EncodedJSON(),
            itemName: OLString.storedTokens
        )
    }

    func deleteTokens() {
        accessControlEncryptedStore.deleteItem(itemName: OLString.storedTokens)
    }
}
