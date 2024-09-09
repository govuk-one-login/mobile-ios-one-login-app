import Foundation
import SecureStore

public struct StoredKeys: Codable {
    var idToken: String
    var accessToken: String
}

public protocol StoredKeyServicing {
    func fetchStoredKeys() throws -> StoredKeys
    func saveStoredKeys(keys: StoredKeys) throws
}

final class StoredKeyService: StoredKeyServicing {
    private let accessControlEncryptedStore: SecureStorable

    init(accessControlEncryptedStore: SecureStorable) {
        self.accessControlEncryptedStore = accessControlEncryptedStore
    }
    
    func fetchStoredKeys() throws -> StoredKeys {
        let storedKeys = try accessControlEncryptedStore.readItem(itemName: .storedTokens)
        guard let keysAsData = Data(base64Encoded: storedKeys) else {
                    // Change returned error
                    throw TokenError.bearerNotPresent
                }
        let decodedKeys = try JSONDecoder().decode(StoredKeys.self, from: keysAsData)
        print("idToken: \(decodedKeys.idToken)")
        print("accessToken: \(decodedKeys.accessToken)")
        return decodedKeys
    }
    
    func saveStoredKeys(keys: StoredKeys) throws {
        print("KEYS: \(keys)")
        let data = try? JSONEncoder().encode(keys)
        guard let encodedData = data?.base64EncodedString() else {
            print("Nothing here, chief")
            return
        }
        try accessControlEncryptedStore.saveItem(item: encodedData, itemName: .storedTokens)
        print("save successful")
    }

}
