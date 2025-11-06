import Foundation
import LocalAuthenticationWrapper
import SecureStore

extension SecureStorable where Self == SecureStoreService {
    static func v12AccessControlEncryptedStore(
        localAuthManager: LocalAuthenticationContextStrings
    ) throws -> SecureStoreService {
        let accessControlConfiguration = SecureStorageConfiguration(
            id: OLString.v12TokensStore,
            accessControlLevel: .anyBiometricsOrPasscode,
            localAuthStrings: try localAuthManager.oneLoginStrings
        )
        return SecureStoreService(
            configuration: accessControlConfiguration
        )
    }
    
    static func v13AccessControlEncryptedStore(
        localAuthManager: LocalAuthenticationContextStrings
    ) throws -> SecureStoreService {
        let accessControlConfiguration = SecureStorageConfiguration(
            id: OLString.v13TokensStore,
            accessControlLevel: .anyBiometricsOrPasscode,
            localAuthStrings: try localAuthManager.oneLoginStrings
        )
        return SecureStoreService(
            configuration: accessControlConfiguration
        )
    }
    
    static func v12EncryptedStore() -> SecureStoreService {
        let encryptedConfiguration = SecureStorageConfiguration(
            id: OLString.v12TokenInfoStore,
            accessControlLevel: .open
        )
        return SecureStoreService(configuration: encryptedConfiguration)
    }
    
    static func v13EncryptedStore() -> SecureStoreService {
        let encryptedConfiguration = SecureStorageConfiguration(
            id: OLString.v13TokenInfoStore,
            accessControlLevel: .open
        )
        return SecureStoreService(configuration: encryptedConfiguration)
    }
}

extension SecureStorable {
    func saveDate(
        id: String,
        _ date: Date
    ) throws {
        try saveItem(
            item: date.timeIntervalSince1970.description,
            itemName: id
        )
    }
    
    func readDate(id: String) throws -> Date {
        let dateString = try readItem(itemName: id)
        guard let dateDouble = Double(dateString) else {
            throw SecureStoreError.cantDecodeData
        }
        return Date(timeIntervalSince1970: dateDouble)
    }
}
