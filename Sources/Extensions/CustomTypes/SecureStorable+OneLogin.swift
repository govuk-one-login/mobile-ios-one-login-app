import Foundation
import LocalAuthenticationWrapper
import SecureStore

extension SecureStorableV2 where Self == SecureStoreServiceV2 {
    static func v12AccessControlEncryptedStore(
        localAuthManager: LocalAuthenticationContextStrings
    ) throws -> SecureStoreServiceV2 {
        let accessControlConfiguration = SecureStorageConfiguration(
            id: OLString.v12TokensStore,
            accessControlLevel: .anyBiometricsOrPasscode,
            localAuthStrings: try localAuthManager.oneLoginStrings
        )
        return SecureStoreServiceV2(
            configuration: accessControlConfiguration
        )
    }
    
    static func v13AccessControlEncryptedStore(
        localAuthManager: LocalAuthenticationContextStrings
    ) throws -> SecureStoreServiceV2 {
        let accessControlConfiguration = SecureStorageConfiguration(
            id: OLString.v13TokensStore,
            accessControlLevel: .anyBiometricsOrPasscode,
            localAuthStrings: try localAuthManager.oneLoginStrings
        )
        return SecureStoreServiceV2(
            configuration: accessControlConfiguration
        )
    }
    
    static func v12EncryptedStore() -> SecureStoreServiceV2 {
        let encryptedConfiguration = SecureStorageConfiguration(
            id: OLString.v12TokenInfoStore,
            accessControlLevel: .open
        )
        return SecureStoreServiceV2(configuration: encryptedConfiguration)
    }
    
    static func v13EncryptedStore() -> SecureStoreServiceV2 {
        let encryptedConfiguration = SecureStorageConfiguration(
            id: OLString.v13TokenInfoStore,
            accessControlLevel: .open
        )
        return SecureStoreServiceV2(configuration: encryptedConfiguration)
    }
}

extension SecureStorableV2 {
    func saveDate(
        id: String,
        _ date: Date
    ) throws {
        try saveItem(
            item: date.timeIntervalSince1970.description,
            itemName: id
        )
    }
    
    func readDate(
        id: String
    ) throws -> Date {
        let dateString = try readItem(itemName: id)
        guard let dateDouble = Double(dateString) else {
            throw SecureStoreErrorV2(.cantDecodeData)
        }
        return Date(timeIntervalSince1970: dateDouble)
    }
}

extension SecureStoreServiceV2: SessionBoundData {
    func clearSessionData() {
        OLString.EncryptedStoreKeyString.allCases
            .forEach { deleteItem(itemName: $0.rawValue) }
        OLString.AccessControlEncryptedStoreKeyString.allCases
            .forEach { deleteItem(itemName: $0.rawValue) }
    }
}
