import LocalAuthenticationWrapper
import SecureStore

final class AccessControlEncryptedSecureStoreManager: SecureStoreManaging, SessionBoundData {
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
    
    func clearSessionData() {
        OLString.AccessControlEncryptedStoreKeyString.allCases
            .forEach { deleteItem($0.rawValue) }
    }
}
