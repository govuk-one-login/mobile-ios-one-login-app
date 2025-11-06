import SecureStore

final class EncryptedSecureStoreManager: SecureStoreManaging, SessionBoundData {
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
    
    func clearSessionData() {
        OLString.EncryptedStoreKeyString.allCases
            .forEach { deleteItem($0.rawValue) }
    }
}
