import GDSCommon
import LocalAuthenticationWrapper
import SecureStore

extension SecureStorable where Self == SecureStoreService {
    static func accessControlEncryptedStore(
        localAuthManager: LocalAuthWrap & LocalAuthenticationContextStringCheck
    ) throws -> SecureStoreService {
        let accessControlConfiguration = SecureStorageConfiguration(
            id: OLString.oneLoginTokens,
            accessControlLevel: try localAuthManager.type == .passcode ?
                .anyBiometricsOrPasscode : .currentBiometricsOrPasscode,
            localAuthStrings: try localAuthManager.oneLoginStrings
        )
        return SecureStoreService(
            configuration: accessControlConfiguration
        )
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
