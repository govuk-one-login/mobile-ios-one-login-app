import SecureStore

extension SecureStorable where Self == SecureStoreService {
    static func accessControlEncryptedStore(
        localAuthManager: LocalAuthenticationManager & LocalAuthenticationContextStringCheck
    ) -> SecureStoreService {
        let accessControlConfiguration = SecureStorageConfiguration(
            id: OLString.oneLoginTokens,
            accessControlLevel: localAuthManager.type == .passcodeOnly ?
                .anyBiometricsOrPasscode : .currentBiometricsOrPasscode,
            localAuthStrings: localAuthManager.contextStrings
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
