import Foundation
import LocalAuthenticationWrapper
import SecureStore

final class AccessControlEncryptedSecureStoreMigrator: SecureStorable, SessionBoundData {
    let v12AccessControlEncryptedSecureStore: SecureStorable
    let v13AccessControlEncryptedSecureStore: SecureStorable
    let migrationStore: DefaultsStoring
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
            migrationStore: UserDefaults.standard,
            analyticsService: analyticsService
        )
    }
    
    init(
        v12AccessControlEncryptedSecureStore: SecureStorable,
        v13AccessControlEncryptedSecureStore: SecureStorable,
        migrationStore: DefaultsStoring,
        analyticsService: OneLoginAnalyticsService
    ) {
        self.v12AccessControlEncryptedSecureStore = v12AccessControlEncryptedSecureStore
        self.v13AccessControlEncryptedSecureStore = v13AccessControlEncryptedSecureStore
        self.migrationStore = migrationStore
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
        // store "saved in new store" for use next time user needs to read from store
        migrationStore.set(true, forKey: OLString.migratedAccessControlEncryptedStoreToV13)
    }
    
    func readItem(itemName: String = OLString.storedTokens) throws -> String {
        guard migrationStore.bool(forKey: OLString.migratedAccessControlEncryptedStoreToV13) else {
            do {
                let loginTokens = try v12AccessControlEncryptedSecureStore.readItem(itemName: itemName)
                // overwrite the token which exists in local storage
                try saveItem(item: loginTokens)
                // log migrated secure store instances
                analyticsService.logCrash(SecureStoreMigrationError.migratedFromV12ToV13)
                return loginTokens
            } catch {
                let loginTokens = try v13AccessControlEncryptedSecureStore.readItem(itemName: itemName)
                migrationStore.set(true, forKey: OLString.migratedAccessControlEncryptedStoreToV13)
                return loginTokens
            }
        }
        return try v13AccessControlEncryptedSecureStore.readItem(itemName: itemName)
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
