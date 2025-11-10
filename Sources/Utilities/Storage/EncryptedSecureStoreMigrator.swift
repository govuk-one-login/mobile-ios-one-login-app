import Foundation
import SecureStore

final class EncryptedSecureStoreMigrator: SecureStorable, SessionBoundData {
    let v12EncryptedSecureStore: SecureStorable
    let v13EncryptedSecureStore: SecureStorable
    let migrationStore: DefaultsStoring
    let analyticsService: OneLoginAnalyticsService
    
    var hasMigrated: Bool {
        get {
            migrationStore.bool(forKey: OLString.migratedAccessControlEncryptedStoreToV13)
        }
        set {
            migrationStore.set(true, forKey: OLString.migratedAccessControlEncryptedStoreToV13)
        }
    }
    
    convenience init(analyticsService: OneLoginAnalyticsService) {
        self.init(
            v12EncryptedSecureStore: .v12EncryptedStore(),
            v13EncryptedSecureStore: .v13EncryptedStore(),
            migrationStore: UserDefaults.standard,
            analyticsService: analyticsService
        )
    }
    
    init(
        v12EncryptedSecureStore: SecureStorable,
        v13EncryptedSecureStore: SecureStorable,
        migrationStore: DefaultsStoring,
        analyticsService: OneLoginAnalyticsService
    ) {
        self.v12EncryptedSecureStore = v12EncryptedSecureStore
        self.v13EncryptedSecureStore = v13EncryptedSecureStore
        self.migrationStore = migrationStore
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
        // store "saved in new store" for use next time user needs to read from store
        hasMigrated = true
    }
    
    func readItem(itemName: String) throws -> String {
        guard hasMigrated else {
            do {
                let item = try v12EncryptedSecureStore.readItem(itemName: itemName)
                // overwrite the token which exists in local storage
                try saveItem(
                    item: item,
                    itemName: itemName
                )
                // log migrated secure store instances
                analyticsService.logCrash(SecureStoreMigrationError.migratedFromV12ToV13)
                return item
            } catch {
                let item = try v13EncryptedSecureStore.readItem(itemName: itemName)
                hasMigrated = true
                return item
            }
        }
        return try v13EncryptedSecureStore.readItem(itemName: itemName)
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
