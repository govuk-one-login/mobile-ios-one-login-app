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
            localAuthManager: localAuthManager,
            analytics: analytics
        )
    }

    static func makeV13TokensStoreConfigurationWithMocks(
        localAuthManager: LocalAuthenticationContextStrings = LocalAuthenticationWrapper.make(localAuthPromptStore: UserDefaults.standard),
        analytics: OneLoginAnalyticsService = MockAnalyticsService()
    ) -> SecureStorageConfiguration {
        return SecureStorageConfiguration.makeV13TokensStoreConfiguration(
            localAuthManager: localAuthManager,
            analytics: analytics
        )
    }
}

struct SecureStorableTests {
    func assertTokenStoreConfigurationThrows(
        errorFromOneLoginStrings: LAError,
        makeTokenStoreConfiguration: (LocalAuthenticationContextStrings, OneLoginAnalyticsService) -> SecureStorageConfiguration
    ) throws {
        // GIVEN localAuthManager throws an error when accessing the oneLoginStrings
        let localAuthManager = MockLocalAuthManager.errorFromOneLoginStringsAsFunction(error: errorFromOneLoginStrings)
        let analytics = MockAnalyticsService()

        let sut = makeTokenStoreConfiguration(localAuthManager, analytics)

        // WHEN accessing the oneLoginStrings
        let localAuthStrings = sut.localAuthStringsProvider()

        // THEN expect crashes to be logged
        #expect(analytics.crashesLogged.count == 1)
        let crash = try #require(analytics.crashesLogged.first as? LAError)

        #expect(crash == errorFromOneLoginStrings)
        #expect(localAuthStrings == sut.localAuthStrings)
        }

    @Test
    func assert_v12TokenStoreConfiguration_localAuthStringsProvider_error() throws {
        let anyError = LAError(.passcodeNotSet)

        try assertTokenStoreConfigurationThrows(errorFromOneLoginStrings: anyError) { localAuthManager, analytics in
            return .makeV12TokensStoreConfigurationWithMocks(
                    localAuthManager: localAuthManager,
                    analytics: analytics
                )
        }
    }

    @Test
    func assert_v13TokenStoreConfiguration_localAuthStringsProvider_error() throws {
        let anyError = LAError(.passcodeNotSet)

        try assertTokenStoreConfigurationThrows(errorFromOneLoginStrings: anyError) { localAuthManager, analytics in
            return .makeV13TokensStoreConfigurationWithMocks(
                    localAuthManager: localAuthManager,
                    analytics: analytics
                )
        }
    }

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
