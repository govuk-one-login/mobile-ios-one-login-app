import LocalAuthenticationWrapper
import SecureStore

extension SecureStorable where Self == SecureStoreService {
    static func accessControlEncryptedStore(
        localAuthManager: LocalAuthManaging & LocalAuthenticationContextStrings
    ) throws -> SecureStoreService {
        #if targetEnvironment(simulator)
        let config = SecureStorageConfiguration(
            id: OLString.oneLoginTokens,
            accessControlLevel: .open,
            localAuthStrings: try localAuthManager.oneLoginStrings
        )
        return SecureStoreService(
            configuration: config
        )
        #else
        let accessControlConfiguration = SecureStorageConfiguration(
            id: OLString.oneLoginTokens,
            accessControlLevel: .anyBiometricsOrPasscode,
            localAuthStrings: try localAuthManager.oneLoginStrings
        )
        return SecureStoreService(
            configuration: accessControlConfiguration
        )
        #endif
    }
    
    static func encryptedStore() -> SecureStoreService {
        let encryptedConfiguration = SecureStorageConfiguration(
            id: OLString.persistentSessionID,
            accessControlLevel: .open
        )
        return SecureStoreService(configuration: encryptedConfiguration)
    }
}

extension SecureStoreService: SessionBoundData { }
