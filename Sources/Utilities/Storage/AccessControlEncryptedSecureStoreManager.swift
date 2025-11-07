import LocalAuthenticationWrapper
import SecureStore

final class AccessControlEncryptedSecureStoreManager: SecureStoreMigrationManaging, SessionBoundData {
    let v12AccessControlEncryptedSecureStore: SecureStorable
    let v13AccessControlEncryptedSecureStore: SecureStorable
    let analyticsService: OneLoginAnalyticsService
    
    convenience init(analyticsService: OneLoginAnalyticsService) throws {
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
            ),
            analyticsService: analyticsService
        )
    }
    
    init(
        v12AccessControlEncryptedSecureStore: SecureStorable,
        v13AccessControlEncryptedSecureStore: SecureStorable,
        analyticsService: OneLoginAnalyticsService
    ) {
        self.v12AccessControlEncryptedSecureStore = v12AccessControlEncryptedSecureStore
        self.v13AccessControlEncryptedSecureStore = v13AccessControlEncryptedSecureStore
        self.analyticsService = analyticsService
    }
    
    func checkItemExists(_ itemName: String = OLString.storedTokens) -> Bool {
        v12AccessControlEncryptedSecureStore.checkItemExists(itemName: itemName) ||
        v13AccessControlEncryptedSecureStore.checkItemExists(itemName: itemName)
    }
    
    func saveItemTov13RemoveFromv12(
        _ item: String,
        itemName: String = OLString.storedTokens
    ) throws {
        try v13AccessControlEncryptedSecureStore.saveItem(
            item: item,
            itemName: itemName
        )
        v12AccessControlEncryptedSecureStore.deleteItem(itemName: itemName)
    }
    
    func readItem(_ itemName: String = OLString.storedTokens) throws -> String {
        do {
            let v12LoginTokens = try v12AccessControlEncryptedSecureStore.readItem(itemName: itemName)
            try saveItemTov13RemoveFromv12(v12LoginTokens)
            // log migrated secure store instances
            analyticsService.logCrash(SecureStoreMigrationError.migratedFromv12Tov13)
            return v12LoginTokens
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
