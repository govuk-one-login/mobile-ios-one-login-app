import Foundation
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

        return try .make(encryptedStore: mockEncryptedStore,
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
    static func makeNonReturningNonEnrollingUnauthenticatedUserWithoutSavedExpiryDate(
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
}
