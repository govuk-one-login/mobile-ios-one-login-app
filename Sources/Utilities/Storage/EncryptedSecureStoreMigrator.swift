import SecureStore

final class EncryptedSecureStoreMigrator: SecureStorable, SessionBoundData {
    let v12EncryptedSecureStore: SecureStorable
    let v13EncryptedSecureStore: SecureStorable
    let analyticsService: OneLoginAnalyticsService
    
    convenience init(analyticsService: OneLoginAnalyticsService) {
        self.init(
            v12EncryptedSecureStore: .v12EncryptedStore(),
            v13EncryptedSecureStore: .v13EncryptedStore(),
            analyticsService: analyticsService
        )
    }
    
    init(
        v12EncryptedSecureStore: SecureStorable,
        v13EncryptedSecureStore: SecureStorable,
        analyticsService: OneLoginAnalyticsService
    ) {
        self.v12EncryptedSecureStore = v12EncryptedSecureStore
        self.v13EncryptedSecureStore = v13EncryptedSecureStore
        self.analyticsService = analyticsService
    }
    
    func checkItemExists(itemName: String) -> Bool {
        v12EncryptedSecureStore.checkItemExists(itemName: itemName) ||
        v13EncryptedSecureStore.checkItemExists(itemName: itemName)
    }
    
    func saveItem(
        item: String,
        itemName: String
    ) throws {
        try v13EncryptedSecureStore.saveItem(
            item: item,
            itemName: itemName
        )
    }
    
    func readItem(itemName: String) throws -> String {
        do {
            let v12Item = try v12EncryptedSecureStore.readItem(itemName: itemName)
            // overwrite the token which exists in local storage
            try saveItem(item: v12Item, itemName: itemName)
            // log migrated secure store instances
            analyticsService.logCrash(SecureStoreMigrationError.migratedFromv12Tov13)
            return v12Item
        } catch {
            return try v13EncryptedSecureStore.readItem(itemName: itemName)
        }
    }
    
    func deleteItem(itemName: String) {
        v12EncryptedSecureStore.deleteItem(itemName: itemName)
        v13EncryptedSecureStore.deleteItem(itemName: itemName)
    }
    
    func delete() throws {
        try v12EncryptedSecureStore.delete()
        try v13EncryptedSecureStore.delete()
    }
    
    func clearSessionData() {
        OLString.EncryptedStoreKeyString.allCases
            .forEach { deleteItem(itemName: $0.rawValue) }
    }
}
