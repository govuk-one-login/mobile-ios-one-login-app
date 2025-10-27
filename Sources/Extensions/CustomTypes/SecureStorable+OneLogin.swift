import AppIntegrity
import Foundation
import LocalAuthenticationWrapper
import SecureStore

extension SecureStorable where Self == SecureStoreService {
    static func accessControlEncryptedStore(
        localAuthManager: LocalAuthenticationContextStrings
    ) throws -> SecureStoreService {
        let accessControlConfiguration = SecureStorageConfiguration(
            id: OLString.oneLoginTokens,
            accessControlLevel: .anyBiometricsOrPasscode,
            localAuthStrings: try localAuthManager.oneLoginStrings
        )
        return SecureStoreService(
            configuration: accessControlConfiguration
        )
    }
    
    static func encryptedStore() -> SecureStoreService {
        let encryptedConfiguration = SecureStorageConfiguration(
            id: OLString.encryptedStore,
            accessControlLevel: .open
        )
        return SecureStoreService(configuration: encryptedConfiguration)
    }
}

extension SecureStoreService: SessionBoundData { }
