import SecureStore
import LocalAuthenticationWrapper

protocol SecureStoreManaging {
    func checkItemExists(_ itemName: String) -> Bool
    func saveItem(_ item: String, itemName: String) throws
    func readItem(_ itemName: String) throws -> String
    func deleteItem(_ itemName: String)
}

final class AccessControlEncryptedSecureStoreManager: SecureStoreManaging {
    let v12AccessControlEncryptedSecureStore: SecureStorable
    let v13AccessControlEncryptedSecureStore: SecureStorable
    
    convenience init() throws {
        self.init(
            v12AccessControlEncryptedSecureStore: try .v12AccessControlEncryptedStore(
                localAuthManager: LocalAuthenticationWrapper(
                    localAuthStrings: .oneLogin
                )
            ),
            v13AccessControlEncryptedSecureStore: try .v13AccessControlEncryptedStore(
                localAuthManager: LocalAuthenticationWrapper(
                    localAuthStrings: .oneLogin
                )
            )
        )
    }
    
    init(
        v12AccessControlEncryptedSecureStore: SecureStorable,
        v13AccessControlEncryptedSecureStore: SecureStorable
    ) {
        self.v12AccessControlEncryptedSecureStore = v12AccessControlEncryptedSecureStore
        self.v13AccessControlEncryptedSecureStore = v13AccessControlEncryptedSecureStore
    }
    
    func checkItemExists(_ itemName: String = OLString.storedTokens) -> Bool {
        v13AccessControlEncryptedSecureStore.checkItemExists(itemName: itemName)
    }
    
    func saveItem(_ item: String, itemName: String = OLString.storedTokens) throws {
        try v13AccessControlEncryptedSecureStore.saveItem(
            item: item,
            itemName: itemName
        )
    }
    
    func readItem(_ itemName: String = OLString.storedTokens) throws -> String {
        do {
            return try v12AccessControlEncryptedSecureStore.readItem(itemName: itemName)
        } catch {
            return try v13AccessControlEncryptedSecureStore.readItem(itemName: itemName)
        }
    }
    
    func deleteItem(_ itemName: String) {
        v12AccessControlEncryptedSecureStore.deleteItem(itemName: itemName)
        v13AccessControlEncryptedSecureStore.deleteItem(itemName: itemName)
    }
}

final class EncryptedSecureStoreManager: SecureStoreManaging {
    let v12EncryptedSecureStore: SecureStorable
    let v13EncryptedSecureStore: SecureStorable
    
    convenience init() {
        self.init(
            v12EncryptedSecureStore: .v12EncryptedStore(),
            v13EncryptedSecureStore: .v13EncryptedStore()
        )
    }
    
    init(
        v12EncryptedSecureStore: SecureStorable,
        v13EncryptedSecureStore: SecureStorable
    ) {
        self.v12EncryptedSecureStore = v12EncryptedSecureStore
        self.v13EncryptedSecureStore = v13EncryptedSecureStore
    }
    
    func checkItemExists(_ itemName: String) -> Bool {
        v13EncryptedSecureStore.checkItemExists(itemName: itemName)
    }
    
    func saveItem(_ item: String, itemName: String) throws {
        try v13EncryptedSecureStore.saveItem(
            item: item,
            itemName: itemName
        )
    }
    
    func readItem(_ itemName: String) throws -> String {
        do {
            return try v12EncryptedSecureStore.readItem(itemName: itemName)
        } catch {
            return try v13EncryptedSecureStore.readItem(itemName: itemName)
        }
    }
    
    func deleteItem(_ itemName: String) {
        v12EncryptedSecureStore.deleteItem(itemName: itemName)
        v13EncryptedSecureStore.deleteItem(itemName: itemName)
    }
}
