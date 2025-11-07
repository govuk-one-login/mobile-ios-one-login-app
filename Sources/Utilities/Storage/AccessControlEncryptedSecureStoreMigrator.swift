import LocalAuthenticationWrapper
import SecureStore

final class AccessControlEncryptedSecureStoreMigrator: SecureStorable, SessionBoundData {
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
    
    func checkItemExists(itemName: String = OLString.storedTokens) -> Bool {
        v12AccessControlEncryptedSecureStore.checkItemExists(itemName: itemName) ||
        v13AccessControlEncryptedSecureStore.checkItemExists(itemName: itemName)
    }
    
    func saveItem(
        item: String,
        itemName: String = OLString.storedTokens
    ) throws {
        try v13AccessControlEncryptedSecureStore.saveItem(
            item: item,
            itemName: itemName
        )
        v12AccessControlEncryptedSecureStore.deleteItem(itemName: itemName)
    }
    
    func readItem(itemName: String = OLString.storedTokens) throws -> String {
        do {
            let v12LoginTokens = try v12AccessControlEncryptedSecureStore.readItem(itemName: itemName)
            try saveItem(item: v12LoginTokens)
            // log migrated secure store instances
            analyticsService.logCrash(SecureStoreMigrationError.migratedFromv12Tov13)
            return v12LoginTokens
        } catch {
            return try v13AccessControlEncryptedSecureStore.readItem(itemName: itemName)
        }
    }
    
    func deleteItem(itemName: String = OLString.storedTokens) {
        v12AccessControlEncryptedSecureStore.deleteItem(itemName: itemName)
        v13AccessControlEncryptedSecureStore.deleteItem(itemName: itemName)
    }
    
    func delete() throws {
        try v12AccessControlEncryptedSecureStore.delete()
        try v13AccessControlEncryptedSecureStore.delete()
    }
    
    func clearSessionData() {
        OLString.AccessControlEncryptedStoreKeyString.allCases
            .forEach { deleteItem(itemName: $0.rawValue) }
    }
}
