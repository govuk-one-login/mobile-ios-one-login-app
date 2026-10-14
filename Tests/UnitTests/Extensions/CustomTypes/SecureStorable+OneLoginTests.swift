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
    func given(errorFromOneLoginStrings: LAError,
               sut: (LocalAuthenticationContextStrings, OneLoginAnalyticsService) -> SecureStorageConfiguration,
               when: (SecureStorageConfiguration) throws -> Void) throws {
        // GIVEN localAuthManager throws an error when accessing the oneLoginStrings
        let localAuthManager = MockLocalAuthManager.errorFromOneLoginStringsAsFunction(error: errorFromOneLoginStrings)
        let analytics = MockAnalyticsService()

        let sut = sut(localAuthManager, analytics)

        #expect(throws: errorFromOneLoginStrings.self) {
            try when(sut)
        }

        // THEN expect crashes to be logged
        #expect(analytics.crashesLogged.count == 1)
        let crash = try #require(analytics.crashesLogged.first as? LAError)

        #expect(crash == errorFromOneLoginStrings)
    }

    @Test
    func assert_v12TokenStoreConfiguration_localAuthStringsProvider_error() throws {
        let anyError = LAError(.passcodeNotSet)

        try given(errorFromOneLoginStrings: anyError, sut: { localAuthManager, analytics in
            return .makeV12TokensStoreConfigurationWithMocks(
                    localAuthManager: localAuthManager,
                    analytics: analytics
                )
        }, when: { sut in
            // WHEN accessing the oneLoginStrings
            _ = try sut.localAuthStringsProvider()
        })
    }

    @Test
    func assert_v13TokenStoreConfiguration_localAuthStringsProvider_error() throws {
        let anyError = LAError(.passcodeNotSet)

        try given(errorFromOneLoginStrings: anyError, sut: { localAuthManager, analytics in
            return .makeV13TokensStoreConfigurationWithMocks(
                    localAuthManager: localAuthManager,
                    analytics: analytics
                )
        }, when: { sut in
            // WHEN accessing the oneLoginStrings
            _ = try sut.localAuthStringsProvider()
        })
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
