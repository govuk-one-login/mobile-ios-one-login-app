import Foundation
import LocalAuthenticationWrapper
import Logging
@testable import OneLogin

extension PersistentSessionManager {
    /// Creates a `PersistentSessionManager` with the following conditions:
    /// * `persistentID = nil` i.e. not stored in the `encryptedStore`
    /// * `isReturningUser = true`
    /// *  `walletSDK.isEmpty = true`
    ///
    /// A call to `startAuthSession(:using:)` assumes this is "a returning user" that cannot authenticate due to
    /// the missing `persistendId` results  in call to `clearAllSessionData` to delete my session & Wallet data.
    static func makeReturningUnauthenticatedUser(mockAnalyticsService: MockAnalyticsService = MockAnalyticsService(),
                                                 accessControlEncryptedSecureStoreMigrator: MockSecureStoreService = MockSecureStoreService(),
                                                 mockEncryptedStore: MockSecureStoreService = MockSecureStoreService(),
                                                 mockUnprotectedStore: (any DefaultsStoring & SessionBoundData) = MockDefaultsStore(),
                                                 walletSessionData: SessionBoundData = WalletSessionBoundDataStub(),
                                                 refreshTokenExchangeManager: TokenExchangeManaging = MockRefreshTokenExchangeManager(),
                                                 analyticsPreferenceStore: (any AnalyticsPreferenceStore & SessionBoundData) = MockAnalyticsPreferenceStore()
    ) throws -> PersistentSessionManager {
        mockUnprotectedStore.set(
            true,
            forKey: OLString.returningUser
        )

        let walletSDK = MockWalletSDKWrapper()
        walletSDK.isEmpty = true

        return try .make(accessControlEncryptedSecureStoreMigrator: accessControlEncryptedSecureStoreMigrator,
                         encryptedStore: mockEncryptedStore,
                         unprotectedStore: mockUnprotectedStore,
                         analyticsService: mockAnalyticsService,
                         walletSDK: walletSDK,
                         walletSessionData: walletSessionData,
                         refreshTokenExchangeManager: refreshTokenExchangeManager,
                         serialTaskQueue: SerialTaskQueue(),
                         analyticsPreferenceStore: analyticsPreferenceStore)
    }

    /// Creates a `PersistentSessionManager` with the following conditions:
    /// * `isEnrolling = false`
    /// * `isReturningUser = true`
    /// * `persistentID = [random uuid]`
    /// *  `walletSDK.isEmpty = true`
    ///
    /// A call to `startAuthSession(:using:)` assumes this is "a returning user" with a `sessionState` that is `.nonePresent` due to a missing `expiryDate`.
    static func makeReturningNonEnrollingUnauthenticatedUserWithoutSavedExpiryDate(
        mockAnalyticsService: MockAnalyticsService = MockAnalyticsService(),
        accessControlEncryptedSecureStoreMigrator: MockSecureStoreService = MockSecureStoreService(),
        mockEncryptedStore: MockSecureStoreService = MockSecureStoreService(),
        mockUnprotectedStore: (any DefaultsStoring & SessionBoundData) = MockDefaultsStore(),
        walletSessionData: SessionBoundData = WalletSessionBoundDataStub(),
        refreshTokenExchangeManager: TokenExchangeManaging = MockRefreshTokenExchangeManager(),
        analyticsPreferenceStore: (any AnalyticsPreferenceStore & SessionBoundData) = MockAnalyticsPreferenceStore()
    ) throws -> PersistentSessionManager {
        mockUnprotectedStore.set(
            true,
            forKey: OLString.returningUser
        )

        try mockEncryptedStore.saveItem(
            item: UUID().uuidString,
            itemName: OLString.persistentSessionID
        )

        let walletSDK = MockWalletSDKWrapper()
        walletSDK.isEmpty = true

        let persistentSessionManager: PersistentSessionManager = try .make(
                         accessControlEncryptedSecureStoreMigrator: accessControlEncryptedSecureStoreMigrator,
                         encryptedStore: mockEncryptedStore,
                         unprotectedStore: mockUnprotectedStore,
                         analyticsService: mockAnalyticsService,
                         walletSDK: walletSDK,
                         walletSessionData: walletSessionData,
                         refreshTokenExchangeManager: refreshTokenExchangeManager,
                         serialTaskQueue: SerialTaskQueue(),
                         analyticsPreferenceStore: analyticsPreferenceStore)

        persistentSessionManager.isEnrolling = false
        return persistentSessionManager
    }

    /// Creates a `PersistentSessionManager` with the following conditions:
    /// * `isEnrolling = false`
    /// * `persistentID = nil` i.e. not stored in the `encryptedStore`
    /// * `isReturningUser = false`
    /// *  `walletSDK.isEmpty = true`
    ///
    /// A call to `startAuthSession(:using:)` assumes this is "a new user" with a `sessionState` that is `.nonePresent` due to a missing `expiryDate`.
    static func makeWithMocks(
        mockAnalyticsService: OneLoginAnalyticsService = MockAnalyticsService(),
        mockAccessControlEncryptedSecureStoreMigrator: MockSecureStoreService = MockSecureStoreService(),
        mockEncryptedStore: MockSecureStoreService = MockSecureStoreService(),
        mockUnprotectedStore: (any DefaultsStoring & SessionBoundData) = MockDefaultsStore(),
        mockWalletSessionData: SessionBoundData = WalletSessionBoundDataStub(),
        mockLocalAuthentication: LocalAuthManaging = MockLocalAuthManager(),
        mockWalletSDK: WalletServiceProtocol = MockWalletSDKWrapper(),
        mockRefreshTokenExchangeManager: TokenExchangeManaging = MockRefreshTokenExchangeManager(),
        mockAnalyticsPreferenceStore: (any AnalyticsPreferenceStore & SessionBoundData) = MockAnalyticsPreferenceStore()
    ) throws -> PersistentSessionManager {
        return try .make(
                accessControlEncryptedSecureStoreMigrator: mockAccessControlEncryptedSecureStoreMigrator,
                encryptedStore: mockEncryptedStore,
                unprotectedStore: mockUnprotectedStore,
                localAuthentication: mockLocalAuthentication,
                analyticsService: mockAnalyticsService,
                walletSDK: mockWalletSDK,
                walletSessionData: mockWalletSessionData,
                refreshTokenExchangeManager: mockRefreshTokenExchangeManager,
                serialTaskQueue: SerialTaskQueue(),
                analyticsPreferenceStore: mockAnalyticsPreferenceStore
            )
    }

    static func makeForResumeSession(
        mockAnalyticsService: MockAnalyticsService = MockAnalyticsService(),
        mockAccessControlEncryptedSecureStoreMigrator: MockSecureStoreService = MockSecureStoreService(),
        mockEncryptedStore: MockSecureStoreService = MockSecureStoreService(),
        mockUnprotectedStore: MockDefaultsStore = MockDefaultsStore(),
        mockWalletSessionData: SessionBoundData = WalletSessionBoundDataStub(),
        mockLocalAuthentication: MockLocalAuthManager = MockLocalAuthManager(),
        mockWalletSDK: WalletServiceProtocol = MockWalletSDKWrapper(),
        mockRefreshTokenExchangeManager: TokenExchangeManaging = MockRefreshTokenExchangeManager(),
        mockAnalyticsPreferenceStore: (any AnalyticsPreferenceStore & SessionBoundData) = MockAnalyticsPreferenceStore()
    ) throws -> PersistentSessionManager {
        // GIVEN I am a returning user with local auth enabled
        mockLocalAuthentication.localAuthIsEnabledOnTheDevice = true
        mockUnprotectedStore.savedData = [OLString.returningUser: true]

        // AND I have a persistentSessionID saved in secure store
        try mockEncryptedStore.saveItem(
            item: UUID().uuidString,
            itemName: OLString.persistentSessionID
        )

        // AND I have tokens saved in secure store
        let data = StoredTokens.encodeKeys(
            idToken: MockJWTs.genericToken,
            refreshToken: MockJWTs.genericToken,
            accessToken: MockJWTs.genericToken
        )
        try mockAccessControlEncryptedSecureStoreMigrator.saveItem(
            item: data,
            itemName: OLString.storedTokens
        )

        return try .make(
                accessControlEncryptedSecureStoreMigrator: mockAccessControlEncryptedSecureStoreMigrator,
                encryptedStore: mockEncryptedStore,
                unprotectedStore: mockUnprotectedStore,
                localAuthentication: mockLocalAuthentication,
                analyticsService: mockAnalyticsService,
                walletSDK: mockWalletSDK,
                walletSessionData: mockWalletSessionData,
                refreshTokenExchangeManager: mockRefreshTokenExchangeManager,
                serialTaskQueue: SerialTaskQueue(),
                analyticsPreferenceStore: mockAnalyticsPreferenceStore
            )
    }
}

extension PersistentSessionManager {
    var hasNotRemovedLocalAuth: Bool {
        get throws {
            try localAuthentication.canUseAnyLocalAuth && isReturningUser
        }
    }
}
