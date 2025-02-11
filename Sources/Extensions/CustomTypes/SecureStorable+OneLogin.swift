import SecureStore

extension SecureStorable where Self == SecureStoreService {
    static func accessControlEncryptedStore(
        localAuthManager: LocalAuthenticationManager & LocalAuthenticationContextStringCheck
    ) -> SecureStoreService {
        let accessControlConfiguration = SecureStorageConfiguration(
            id: .oneLoginTokens,
            accessControlLevel: localAuthManager.type == .passcodeOnly ?
                .anyBiometricsOrPasscode : .currentBiometricsOrPasscode,
            localAuthStrings: localAuthManager.contextStrings
        )
        return SecureStoreService(
            configuration: accessControlConfiguration
        )
    }
}

extension SecureStoreService: SessionBoundData { }
