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
        // how decode data as it returns as string
        // need to put it as base64 like this:
       
        let keysAsData = storedKeys.data(using: .utf8)
        let decodedKeys = try JSONDecoder().decode(StoredKeys.self, from: keysAsData!)
        let keys = StoredKeys(idToken: decodedKeys.idToken, accessToken: decodedKeys.accessToken)
        print("keys: \(keys)")
        return keys
    }
    
    func saveStoredKeys(keys: StoredKeys) throws {
        let data = try? JSONEncoder().encode(keys)
        guard let encodedData = data?.base64EncodedString() else {
            print("Nothing here, chief")
            return
        }
        try accessControlEncryptedStore.saveItem(item: encodedData, itemName: .storedTokens)
        print("save successful")
    }

}
