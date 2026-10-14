import LocalAuthentication
@testable import LocalAuthenticationWrapper
@testable import OneLogin
@testable import SecureStore
import Testing

extension SecureStorageConfiguration {
    static func makeV12TokensStoreConfigurationWithMocks(
        localAuthManager: LocalAuthenticationContextStrings = LocalAuthenticationWrapper.make(localAuthPromptStore: UserDefaults.standard),
        analytics: OneLoginAnalyticsService = MockAnalyticsService()
    ) -> SecureStorageConfiguration {
        return SecureStorageConfiguration.makeV12TokensStoreConfiguration(
            localAuthManager: localAuthManager
        )
    }

    static func makeV13TokensStoreConfigurationWithMocks(
        localAuthManager: LocalAuthenticationContextStrings = LocalAuthenticationWrapper.make(localAuthPromptStore: UserDefaults.standard),
        analytics: OneLoginAnalyticsService = MockAnalyticsService()
    ) -> SecureStorageConfiguration {
        return SecureStorageConfiguration.makeV13TokensStoreConfiguration(
            localAuthManager: localAuthManager
        )
    }
}

struct SecureStorableTests {
    @Test
    func assert_v12EncryptedStore() {
        let sut = SecureStoreService.v12EncryptedStore()
        #expect(sut.keyManagerService.configuration.id == OLString.v12TokenInfoStore)
        #expect(sut.keyManagerService.configuration.accessControlLevel == .open)
    }

    @Test
    func assert_v13EncryptedStore() {
        let sut = SecureStoreService.v13EncryptedStore()
        #expect(sut.keyManagerService.configuration.id == OLString.v13TokenInfoStore)
        #expect(sut.keyManagerService.configuration.accessControlLevel == .open)
    }
}
