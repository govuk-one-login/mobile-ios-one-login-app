// swiftlint:disable file_length
import AppIntegrity
import Authentication
import Logging
import MockNetworking
@testable import Networking
@testable @preconcurrency import OneLogin
import SecureStore
import Security
import Testing
import UIKit
import WalletStore

struct SessionBoundDataExpectation: SessionBoundData {
    let onClearSessionData: () -> Void
    
    func clearSessionData() {
        self.onClearSessionData()
    }
}

class MockSessionBoundData: SessionBoundData {
    var didCall_deleteSessionBoundData = false
    
    func clearSessionData() {
        didCall_deleteSessionBoundData = true
    }
}

// swiftlint:disable type_body_length
struct PersistentSessionManagerTests {
    @Test
    func test_initialState() throws {
        let sut: PersistentSessionManager = try .makeWithMocks()
        #expect(sut.expiryDate == nil)
        #expect(sut.isSessionValid == false)
        #expect(sut.isReturningUser == false)
        #expect(sut.isEnrolling == false)
        #expect(sut.sessionState == .nonePresent)
    }
    
    @Test
    func test_sessionExpiryDate_refreshToken() throws {
        let mockEncryptedStore: MockSecureStoreService = MockSecureStoreService()
        let sut: PersistentSessionManager = try .makeWithMocks(mockEncryptedStore: mockEncryptedStore)

        // GIVEN the encrypted store contains a refresh token expiry date
        let date = Date.distantFuture
        try mockEncryptedStore.saveItem(
            item: date.timeIntervalSince1970.description,
            itemName: OLString.refreshTokenExpiry
        )
        // THEN it is exposed by the session manager
        #expect(sut.expiryDate == date.withFifteenSecondBuffer)
    }
    
    @Test
    func test_sessionExpiryDate_bothTokensSet() throws {
        let mockEncryptedStore = MockSecureStoreService()
        let mockUnprotectedStore = MockDefaultsStore()
        let sut: PersistentSessionManager = try .makeWithMocks(mockEncryptedStore: mockEncryptedStore,
                                                               mockUnprotectedStore: mockUnprotectedStore)

        // GIVEN the encrypted store contains a refresh token expiry date
        let refreshTokenExpiryDate = Date.distantFuture
        try mockEncryptedStore.saveItem(
            item: refreshTokenExpiryDate.timeIntervalSince1970.description,
            itemName: OLString.refreshTokenExpiry
        )
        
        // AND the unprotected store contains an access token expiry date
        let accessTokenExpiryDate = Date()
        mockUnprotectedStore.set(
            accessTokenExpiryDate,
            forKey: OLString.accessTokenExpiry
        )
        
        // THEN date exposed by the session manager matches refresh token expiry date
        #expect(sut.expiryDate == refreshTokenExpiryDate.withFifteenSecondBuffer)
    }
    
    @Test
    func test_sessionExpiryDate_accessToken() throws {
        let mockUnprotectedStore = MockDefaultsStore()
        let sut: PersistentSessionManager = try .makeWithMocks(mockUnprotectedStore: mockUnprotectedStore)

        // GIVEN the unprotected store contains an access token expiry date
        let date = Date()
        mockUnprotectedStore.set(
            date,
            forKey: OLString.accessTokenExpiry
        )
        // THEN it is exposed by the session manager
        #expect(sut.expiryDate == date.withFifteenSecondBuffer)
    }
    
    @Test
    func test_sessionIsValid_refreshToken_notExpired() throws {
        let mockEncryptedStore = MockSecureStoreService()
        let mockUnprotectedStore = MockDefaultsStore()
        let sut: PersistentSessionManager = try .makeWithMocks(mockEncryptedStore: mockEncryptedStore,
                                                               mockUnprotectedStore: mockUnprotectedStore)

        // GIVEN the unprotected store contains a refresh token expiry date in the future
        try mockEncryptedStore.saveItem(
            item: Date.distantFuture.timeIntervalSince1970.description,
            itemName: OLString.refreshTokenExpiry
        )
        
        // THEN the session is valid
        #expect(sut.isSessionValid)
        #expect(sut.sessionState == .saved)
    }
    
    @Test
    func test_sessionIsValid_accessToken_notExpired() throws {
        let mockUnprotectedStore = MockDefaultsStore()
        let sut: PersistentSessionManager = try .makeWithMocks(mockUnprotectedStore: mockUnprotectedStore)

        // GIVEN the unprotected store contains an access token expiry date in the future
        mockUnprotectedStore.set(
            Date.distantFuture,
            forKey: OLString.accessTokenExpiry
        )
        // THEN the session is valid
        #expect(sut.isSessionValid)
        #expect(sut.sessionState == .saved)
    }
    
    @Test
    func test_sessionIsInvalid_refreshToken_Expired() throws {
        let mockEncryptedStore = MockSecureStoreService()
        let sut: PersistentSessionManager = try .makeWithMocks(mockEncryptedStore: mockEncryptedStore)

        // GIVEN the unprotected store contains a refresh token expiry date in the past
        try mockEncryptedStore.saveItem(
            item: Date.distantPast.timeIntervalSince1970.description,
            itemName: OLString.refreshTokenExpiry
        )
        // THEN the session is not valid
        #expect(sut.isSessionValid == false)
        #expect(sut.sessionState == .expired)
    }
    
    @Test
    func test_sessionIsInvalid_accessToken_Expired() throws {
        let mockUnprotectedStore = MockDefaultsStore()
        let sut: PersistentSessionManager = try .makeWithMocks(mockUnprotectedStore: mockUnprotectedStore)

        // GIVEN the unprotected store contains an access token expiry date in the past
        mockUnprotectedStore.set(
            Date.distantPast,
            forKey: OLString.accessTokenExpiry
        )
        // THEN the session is not valid
        #expect(sut.isSessionValid == false)
        #expect(sut.sessionState == .expired)
    }
    
    @Test
    func test_returnTokensIfValid() throws {
        let mockAccessControlEncryptedStore = MockSecureStoreService()
        let mockEncryptedStore = MockSecureStoreService()
        let sut: PersistentSessionManager = try .makeWithMocks(mockAccessControlEncryptedSecureStoreMigrator: mockAccessControlEncryptedStore,
                                                               mockEncryptedStore: mockEncryptedStore)

        // GIVEN the unprotected store contains an access token expiry date in the future
        try mockEncryptedStore.saveItem(
            item: Date.distantFuture.timeIntervalSince1970.description,
            itemName: OLString.refreshTokenExpiry
        )
        
        // AND a refresh token is stored
        let data = StoredTokens.encodeKeys(
            idToken: MockJWTs.genericToken,
            refreshToken: MockJWTs.genericToken,
            accessToken: MockJWTs.genericToken
        )
        try mockAccessControlEncryptedStore.saveItem(
            item: data,
            itemName: OLString.storedTokens
        )
        
        // THEN a refresh and id token is returned
        #expect(try sut.validTokensForRefreshExchange?.refreshToken == MockJWTs.genericToken)
        #expect(try sut.validTokensForRefreshExchange?.idToken == MockJWTs.genericToken)
    }
    
    @Test
    func test_returnTokensIfValid_expired() throws {
        let mockAccessControlEncryptedStore = MockSecureStoreService()
        let mockEncryptedStore = MockSecureStoreService()
        let sut: PersistentSessionManager = try .makeWithMocks(mockAccessControlEncryptedSecureStoreMigrator: mockAccessControlEncryptedStore,
                                                               mockEncryptedStore: mockEncryptedStore)

        // GIVEN the unprotected store contains an access token expiry date in the past
        try mockEncryptedStore.saveItem(
            item: Date.distantPast.timeIntervalSince1970.description,
            itemName: OLString.refreshTokenExpiry
        )
        
        // AND a refresh token is stored
        let data = StoredTokens.encodeKeys(
            idToken: MockJWTs.genericToken,
            refreshToken: MockJWTs.genericToken,
            accessToken: MockJWTs.genericToken
        )
        try mockAccessControlEncryptedStore.saveItem(
            item: data,
            itemName: OLString.storedTokens
        )
        
        // THEN no refresh token is returned
        #expect(try sut.validTokensForRefreshExchange == nil)
    }
    
    @Test
    func test_isReturningUserPullsFromStore() throws {
        let mockUnprotectedStore = MockDefaultsStore()
        let sut: PersistentSessionManager = try .makeWithMocks(mockUnprotectedStore: mockUnprotectedStore)

        mockUnprotectedStore.set(
            true,
            forKey: OLString.returningUser
        )
        #expect(sut.isReturningUser)
    }
    
    @Test
    func test_persistentID() throws {
        let mockEncryptedStore = MockSecureStoreService()
        let sut: PersistentSessionManager = try .makeWithMocks(mockEncryptedStore: mockEncryptedStore)

        try mockEncryptedStore.saveItem(
            item: "123456789",
            itemName: OLString.persistentSessionID
        )
        #expect(sut.persistentID == "123456789")
    }
    
    @Test
    func test_persistentID_nil() throws {
        let sut: PersistentSessionManager = try .makeWithMocks()

        #expect(sut.persistentID == nil)
    }
    
    @Test
    func test_persistentID_empty() throws {
        let mockEncryptedStore = MockSecureStoreService()
        let sut: PersistentSessionManager = try .makeWithMocks(mockEncryptedStore: mockEncryptedStore)

        try mockEncryptedStore.saveItem(
            item: "",
            itemName: OLString.persistentSessionID
        )
        #expect(sut.persistentID == nil)
    }
    
    @Test
    func test_hasNotRemovedLocalAuth() throws {
        let mockLocalAuthentication = MockLocalAuthManager()
        let mockUnprotectedStore = MockDefaultsStore()
        let sut: PersistentSessionManager = try .makeWithMocks(mockUnprotectedStore: mockUnprotectedStore,
                                                               mockLocalAuthentication: mockLocalAuthentication)

        mockLocalAuthentication.localAuthIsEnabledOnTheDevice = true
        mockUnprotectedStore.set(
            true,
            forKey: OLString.returningUser
        )
        #expect(try sut.hasNotRemovedLocalAuth)
    }
    
    @Test
    func test_hasRemovedLocalAuth() throws {
        let mockLocalAuthentication = MockLocalAuthManager()
        let mockUnprotectedStore = MockDefaultsStore()
        let sut: PersistentSessionManager = try .makeWithMocks(mockUnprotectedStore: mockUnprotectedStore,
                                                               mockLocalAuthentication: mockLocalAuthentication)

        mockLocalAuthentication.localAuthIsEnabledOnTheDevice = false
        mockUnprotectedStore.set(
            true,
            forKey: OLString.returningUser
        )
        #expect(try sut.hasNotRemovedLocalAuth == false)
    }
    
    @Test
    func test_hasRemovedLocalAuth_inverse() throws {
        let mockLocalAuthentication = MockLocalAuthManager()
        let mockUnprotectedStore = MockDefaultsStore()
        let sut: PersistentSessionManager = try .makeWithMocks(mockUnprotectedStore: mockUnprotectedStore,
                                                               mockLocalAuthentication: mockLocalAuthentication)

        mockLocalAuthentication.localAuthIsEnabledOnTheDevice = true
        mockUnprotectedStore.set(
            false,
            forKey: OLString.returningUser
        )
        #expect(try sut.hasNotRemovedLocalAuth == false)
    }
    
    @MainActor
    @Test
    func test_startSession_logsTheUserIn() async throws {
        let sut: PersistentSessionManager = try .makeWithMocks()

        // GIVEN I am not logged in
        let loginSession = MockLoginSession(window: UIWindow())
        // WHEN I start a session
        try await sut.startAuthSession(
            loginSession,
            using: MockLoginSessionConfiguration.oneLoginSessionConfiguration
        )
        // THEN a login screen is shown
        #expect(loginSession.didCallPerformLoginFlow)
        // AND no persistent session ID is provided
        let configuration = try #require(loginSession.sessionConfiguration)
        #expect(configuration.persistentSessionId == "123456789")
        #expect(sut.sessionState == .oneTime)
    }
    
    @MainActor
    @Test
    func test_startSession_logsTheUserIn_appIntegrity() async throws {
        let sut: PersistentSessionManager = try .makeWithMocks()

        AppEnvironment.updateFlags(
            releaseFlags: [:],
            featureFlags: [FeatureFlagsName.appCheckEnabled.rawValue: true]
        )
        // GIVEN I am not logged in
        let loginSession = MockLoginSession(window: UIWindow())
        // WHEN I start a session
        try await sut.startAuthSession(
            loginSession,
            using: MockLoginSessionConfiguration.oneLoginSessionConfiguration
        )
        // THEN a login screen is shown
        #expect(loginSession.didCallPerformLoginFlow)
        // AND no persistent session ID is provided
        let tokenHeaders = try await loginSession.sessionConfiguration?.tokenHeaders()
        let tokenParameters = try await loginSession.sessionConfiguration?.tokenParameters()
        #expect(tokenHeaders == nil)
        #expect(tokenParameters == nil)
    }
    
    @MainActor
    @Test
    func test_startSession_cannotReauthenticateWithoutPersistentSessionID() async throws {
        let mockAnalyticsPrefernceStore = UserDefaultsPreferenceStore()
        mockAnalyticsPrefernceStore.hasAcceptedAnalytics = true
        
        let mockEncryptedStore = MockSecureStoreService()
        let mockUnprotectedStore = MockDefaultsStore()
        let sut: PersistentSessionManager = try .makeWithMocks(mockEncryptedStore: mockEncryptedStore,
                                                               mockUnprotectedStore: mockUnprotectedStore,
                                                               mockAnalyticsPreferenceStore: mockAnalyticsPrefernceStore)

        // GIVEN I am a returning user
        mockUnprotectedStore.set(
            true,
            forKey: OLString.returningUser
        )
        let sessionBoundDataTest = MockSessionBoundData()
        sut.registerSessionBoundData([
            sessionBoundDataTest,
            mockEncryptedStore,
            mockUnprotectedStore,
            mockAnalyticsPrefernceStore
        ])
        // AND I am unable to re-authenticate because I have no persistent session ID
        mockEncryptedStore.deleteItem(itemName: OLString.persistentSessionID)
        
        let systemLogUserOutNotifications = NotificationCenter.default.notifications(named: .systemLogUserOut).makeAsyncIterator()
        
        // WHEN I start a session
        let error = await #expect(throws: PersistentSessionError.self) {
            try await sut.startAuthSession(
                MockLoginSession(window: UIWindow()),
                using: MockLoginSessionConfiguration.oneLoginSessionConfiguration
            )
        }
        
        #expect(error?.kind == .sessionMismatch)
        
        // THEN a session mismatch error is thrown
        // AND my session data is cleared
        #expect(sessionBoundDataTest.didCall_deleteSessionBoundData)
        #expect(mockEncryptedStore.savedItems.isEmpty)
        #expect(mockUnprotectedStore.savedData.isEmpty)
        #expect(mockAnalyticsPrefernceStore.hasAcceptedAnalytics == nil)
        #expect(await systemLogUserOutNotifications.next() != nil)
    }
    
    @MainActor
    @Test
    func test_startSession_noPersistentID_ReturningUser_WalletNotEmptyError() async throws {
        let mockAnalyticsService: MockAnalyticsService = MockAnalyticsService()
        let mockEncryptedStore = MockSecureStoreService()
        let mockUnprotectedStore = MockDefaultsStore()
        let mockWalletSDK = MockWalletSDKWrapper()
        let sut: PersistentSessionManager = try .makeWithMocks(mockAnalyticsService: mockAnalyticsService,
                                                               mockEncryptedStore: mockEncryptedStore,
                                                               mockUnprotectedStore: mockUnprotectedStore,
                                                               mockWalletSDK: mockWalletSDK)

        // GIVEN I am a returning user
        mockUnprotectedStore.set(
            true,
            forKey: OLString.returningUser
        )
        
        // AND I am unable to re-authenticate because I have no persistent session ID
        mockEncryptedStore.deleteItem(itemName: OLString.persistentSessionID)
        // AND the wallet is not empty
        mockWalletSDK.isEmpty = false
        // AND there aren't any errors logged
        #expect(mockAnalyticsService.crashesLogged.count == 0)
        // WHEN I start a session
        let error = await #expect(throws: PersistentSessionError.self) {
            try await sut.startAuthSession(
                MockLoginSession(window: UIWindow()),
                using: MockLoginSessionConfiguration.oneLoginSessionConfiguration
            )
        }
        // THEN a secure wallet data deleted error should be logged because wallet is expected to be empty
        #expect(error?.kind == .sessionMismatch)
        #expect(mockAnalyticsService.crashesLogged.count == 1)
        #expect(mockAnalyticsService.crashesLogged.first as? PersistentSessionError == PersistentSessionError(.sessionMismatch,
                                                                                                              reason: "reason : secure wallet data deleted"))
    }
    
    @MainActor
    @Test
    func test_startSession_noPersistentID_NotReturningUser_WalletNotEmptyError() async throws {
        // Given I am unable to re-authenticate because I have no persistent session ID
        let mockEncryptedStore = MockSecureStoreService()
        mockEncryptedStore.deleteItem(itemName: OLString.persistentSessionID)
        // AND the wallet is not empty
        let mockWalletSDK = MockWalletSDKWrapper()
        mockWalletSDK.isEmpty = false

        try await confirmation("wallet not empty") { confirmation in
            let mockAnalyticsService = MockAnalyticsServiceExpectation(onLogCrashAnyErrorCalled: {
                confirmation()
            })
            let sut: PersistentSessionManager = try .makeWithMocks(mockAnalyticsService: mockAnalyticsService,
                                                                   mockEncryptedStore: mockEncryptedStore,
                                                                   mockWalletSDK: mockWalletSDK)

            // WHEN I start a session
            await #expect(throws: Never.self) {
                try await sut.startAuthSession(
                    MockLoginSession(window: UIWindow()),
                    using: MockLoginSessionConfiguration.oneLoginSessionConfiguration
                )
            }
            
            // THEN a secure wallet data deleted error should be logged because wallet is expected to be empty
            #expect(mockAnalyticsService.crashesLogged.count == 1)
            #expect(mockAnalyticsService.crashesLogged.first as? PersistentSessionError == PersistentSessionError(.noSessionExists,
                                                                                                                  reason: "reason : secure wallet data deleted"))
        }
    }
    
    @MainActor
    @Test
    func test_startSession_clearAppForLogin_exceptAnalyticsPreference() async throws {
        let mockEncryptedStore = MockSecureStoreService()
        let mockUnprotectedStore = MockDefaultsStore()
        
        let mockAnalyticsPrefernceStore = UserDefaultsPreferenceStore()
        mockAnalyticsPrefernceStore.hasAcceptedAnalytics = true
        
        let sut: PersistentSessionManager = try .makeWithMocks(mockEncryptedStore: mockEncryptedStore,
                                                               mockUnprotectedStore: mockUnprotectedStore,
                                                               mockAnalyticsPreferenceStore: mockAnalyticsPrefernceStore)

        try await confirmation("clear app except analytics") { confirmation in
            let sessionBoundDataExpectation = SessionBoundDataExpectation(onClearSessionData: {
                // THEN my session data is cleared
                confirmation()
            })
            
            // GIVEN I am a returning user who previously accepted analytics
            sut.registerSessionBoundData([
                sessionBoundDataExpectation,
                mockEncryptedStore,
                mockUnprotectedStore,
                mockAnalyticsPrefernceStore
            ])
            
            // AND I am unable to re-authenticate because I have no persistent session ID
            mockEncryptedStore.deleteItem(itemName: OLString.persistentSessionID)
            
            // WHEN I start a session
            try await sut.startAuthSession(
                MockLoginSession(window: UIWindow()),
                using: MockLoginSessionConfiguration.oneLoginSessionConfiguration
            )
        }

        #expect(mockEncryptedStore.savedItems.isEmpty)
        #expect(mockUnprotectedStore.savedData.isEmpty)
        
        // AND my analytics preference is still set
        #expect(mockAnalyticsPrefernceStore.hasAcceptedAnalytics == true)
    }
    
    @MainActor
    @Test
    func test_startSession_exposesUserAndAccessToken() async throws {
        let sut: PersistentSessionManager = try .makeWithMocks()

        // GIVEN I am logged in
        // WHEN I start a session
        try await sut.startAuthSession(
            MockLoginSession(window: UIWindow()),
            using: MockLoginSessionConfiguration.oneLoginSessionConfiguration
        )
        // THEN my User details
        #expect(sut.user.value?.persistentID == "af835f3a-b3f1-4b50-b3db-88c185eae46b")
        #expect(sut.walletStoreID == "LpyvURud63e1LDVO0AEf7AJvXUrFlCGRfF-tl63vUe0")
        #expect(sut.user.value?.email == "mock@email.com")
        // AND access token are populated
        #expect(sut.tokenProvider.accessToken == "accessTokenResponse")
    }
    
    @MainActor
    @Test
    func test_startSession_skipsSavingTokensForNewUsers() async throws {
        let mockEncryptedStore = MockSecureStoreService()
        let mockUnprotectedStore = MockDefaultsStore()
        let sut: PersistentSessionManager = try .makeWithMocks(mockEncryptedStore: mockEncryptedStore,
                                                               mockUnprotectedStore: mockUnprotectedStore)

        // GIVEN I am not logged in
        // WHEN I start a session
        try await sut.startAuthSession(
            MockLoginSession(window: UIWindow()),
            using: MockLoginSessionConfiguration.oneLoginSessionConfiguration
        )
        // THEN my session data is not saved
        #expect(mockEncryptedStore.savedItems == [:])
        #expect(mockUnprotectedStore.savedData.count == 0)
    }
    
    @MainActor
    @Test
    func test_startSession_savesTokensForReturningUsers() async throws {
        let mockEncryptedStore = MockSecureStoreService()
        let mockUnprotectedStore = MockDefaultsStore()
        // GIVEN I am a returning user
        mockUnprotectedStore.savedData = [OLString.returningUser: true]
        let persistentSessionID = UUID().uuidString
        try mockEncryptedStore.saveItem(
            item: persistentSessionID,
            itemName: OLString.persistentSessionID
        )
        
        let sut: PersistentSessionManager = try .makeWithMocks(mockEncryptedStore: mockEncryptedStore,
                                                               mockUnprotectedStore: mockUnprotectedStore)

        let enrolmentCompleteNotifications = NotificationCenter.default.notifications(named: .enrolmentComplete).makeAsyncIterator()
        
        // WHEN I re-authenticate
        try await sut.startAuthSession(
            MockLoginSession(window: UIWindow()),
            using: MockLoginSessionConfiguration.oneLoginSessionConfiguration
        )
        
        // THEN the user can be returned to where they left off
        #expect(await enrolmentCompleteNotifications.next() != nil)
        
        // AND my session data is updated in the store
        #expect(mockEncryptedStore.savedItems == [
            OLString.refreshTokenExpiry: "1719397758.0",
            OLString.persistentSessionID: "af835f3a-b3f1-4b50-b3db-88c185eae46b"
        ])
        #expect(mockUnprotectedStore.savedData.count == 2)
    }
    
    @MainActor
    @Test
    func test_saveSession_enrolsLocalAuthenticationForNewUsers() async throws {
        let mockEncryptedStore = MockSecureStoreService()
        let mockUnprotectedStore = MockDefaultsStore()
        // GIVEN I am a new user
        mockUnprotectedStore.savedData = [OLString.returningUser: false]

        let sut: PersistentSessionManager = try .makeWithMocks(mockEncryptedStore: mockEncryptedStore,
                                                               mockUnprotectedStore: mockUnprotectedStore)

        // AND I have logged in
        try await sut.startAuthSession(
            MockLoginSession(window: UIWindow()),
            using: MockLoginSessionConfiguration.oneLoginSessionConfiguration
        )
        // WHEN I attempt to save my session
        try sut.saveAuthSession()
        // THEN my session data is updated in the store
        #expect(mockEncryptedStore.savedItems == [
            OLString.refreshTokenExpiry: "1719397758.0",
            OLString.persistentSessionID: "af835f3a-b3f1-4b50-b3db-88c185eae46b"
        ])
        #expect(mockUnprotectedStore.savedData.count == 2)
    }
    
    @MainActor
    @Test
    func test_saveSession_doesNotRefreshSecureStoreManager() async throws {
        let (mockAccessControlEncryptedStore, mockAccessControlEncryptedStoreClearSessionData) = MockSecureStoreService.mockClearSessionDataCounter()
        try mockAccessControlEncryptedStore.saveItem(
            item: "storedTokens",
            itemName: OLString.storedTokens
        )
        
        let (mockEncryptedStore, mockEncryptedStoreClearSessionData) = MockSecureStoreService.mockClearSessionDataCounter()
        try mockEncryptedStore.saveItem(
            item: UUID().uuidString,
            itemName: OLString.persistentSessionID
        )

        let mockUnprotectedStore = MockDefaultsStore()
        
        // GIVEN I am a new user
        let sut: PersistentSessionManager = try .makeWithMocks(mockAccessControlEncryptedSecureStoreMigrator: mockAccessControlEncryptedStore,
                                                               mockEncryptedStore: mockEncryptedStore,
                                                               mockUnprotectedStore: mockUnprotectedStore)
        
        // AND I have logged in
        try await sut.startAuthSession(
            MockLoginSession(window: UIWindow()),
            using: MockLoginSessionConfiguration.oneLoginSessionConfiguration
        )
        // WHEN I attempt to save my session
        try sut.saveAuthSession()
        // THEN the secure store manager is not refreshed
        #expect(mockAccessControlEncryptedStoreClearSessionData.called() == false)
        #expect(mockEncryptedStoreClearSessionData.called() == false)
        // THEN the session data is updated in the store
        #expect(mockEncryptedStore.savedItems == [
                OLString.refreshTokenExpiry: "1719397758.0",
                OLString.persistentSessionID: "af835f3a-b3f1-4b50-b3db-88c185eae46b"
            ]
        )
        #expect(mockUnprotectedStore.savedData.count == 2)
    }
    
    @Test
    func test_resumeSession_refreshTokenExchange_noLocalAuth() async throws {
        let mockLocalAuthentication = MockLocalAuthManager()
        // GIVEN I am a returning user with local auth enabled and tokens stored
        let sut: PersistentSessionManager = try .makeForResumeSession(mockLocalAuthentication: mockLocalAuthentication)

        // IF I disable local auth
        mockLocalAuthentication.localAuthIsEnabledOnTheDevice = false
        
        // WHEN I attempt to resume my session
        let error = await #expect(throws: PersistentSessionError.self) {
            try await sut.resumeSession()
        }
        // THEN an error is caught
        #expect(error?.kind == .userRemovedLocalAuth)
    }
    
    @Test
    func test_hasNotRemovedLocalAuth_throwsError_whenPasscodeRemoved() async throws {
        let mockLocalAuthentication = MockLocalAuthManager()
        let mockUnprotectedStore = MockDefaultsStore()
        let sut: PersistentSessionManager = try .makeWithMocks(mockUnprotectedStore: mockUnprotectedStore,
                                                               mockLocalAuthentication: mockLocalAuthentication)

        // GIVEN I am a returning user with an active session
        mockUnprotectedStore.savedData = [
            OLString.returningUser: true,
            OLString.accessTokenExpiry: Date.distantFuture
        ]
        // WHEN remove my passcode
        mockLocalAuthentication.localAuthIsEnabledOnTheDevice = false
        
        let error = await #expect(throws: PersistentSessionError.self) {
            try await sut.resumeSession()
        }
        // THEN an error is caught
        #expect(error?.kind == .userRemovedLocalAuth)
    }
    
    @Test
    func test_resumeSession_refreshTokenExchange_noPersistentSessionID() async throws {
        let mockEncryptedStore = MockSecureStoreService()
        let mockUnprotectedStore = MockDefaultsStore()
        let mockLocalAuthentication = MockLocalAuthManager()
        let sut: PersistentSessionManager = try .makeWithMocks(mockEncryptedStore: mockEncryptedStore,
                                                               mockUnprotectedStore: mockUnprotectedStore,
                                                               mockLocalAuthentication: mockLocalAuthentication)

        // GIVEN I am a returning user with local auth enabled
        mockUnprotectedStore.set(
            true,
            forKey: OLString.returningUser
        )
        mockLocalAuthentication.localAuthIsEnabledOnTheDevice = true
        
        // AND I have no persistent session ID
        mockEncryptedStore.deleteItem(itemName: OLString.persistentSessionID)
        #expect(sut.persistentID == nil)
        
        // WHEN I attempt to resume my session
        let error = await #expect(throws: PersistentSessionError.self) {
            try await sut.resumeSession()
        }
        // THEN an error is caught
        #expect(error?.kind == .noSessionExists)
    }
    
    @Test
    func test_resumeSession_refreshTokenExchange_idTokenNotStored() async throws {
        // GIVEN I am a returning user with local auth enabled and tokens stored
        let mockAccessControlEncryptedStore = MockSecureStoreService()
        let mockEncryptedStore = MockSecureStoreService()
        let sut: PersistentSessionManager = try .makeForResumeSession(mockAccessControlEncryptedSecureStoreMigrator: mockAccessControlEncryptedStore,
                                                                      mockEncryptedStore: mockEncryptedStore)
        
        // IF the ID token is no longer stored
        let tokens = StoredTokens.encodeKeys(
            idToken: "",
            refreshToken: "refreshToken",
            accessToken: "accessToken"
        )
        
        try mockAccessControlEncryptedStore.saveItem(
            item: tokens,
            itemName: OLString.storedTokens
        )
        // WHEN I attempt to resume my session
        let error = await #expect(throws: PersistentSessionError.self) {
            try await sut.resumeSession()
        }
        // THEN an error is thrown
        #expect(error?.kind == .idTokenNotStored)
    }
    
    @Test(arguments: [URLError(.notConnectedToInternet), URLError(.networkConnectionLost), URLError(.timedOut)])
    func test_resumeSession_whenRefreshTokenExchangeThrowsError_doesNotThrowError(_ error: URLError) async throws {
        MockURLProtocol.clear()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let client = NetworkClient(configuration: configuration)
        client.clientAttestationProvider = MockAppIntegrityProvider()
        client.dPoPProvider = MockAppIntegrityProvider()

        // GIVEN I am a returning user with local auth enabled and tokens stored
        let refreshTokenExchangeManager = RefreshTokenExchangeManager(networkClient: client)
        let sut: PersistentSessionManager = try .makeForResumeSession(mockRefreshTokenExchangeManager: refreshTokenExchangeManager)

        // AND I have no internet
        MockURLProtocol.handler = {
            throw error
        }
        
        // WHEN I attempt to resume my session
        await #expect(throws: Never.self) {
            try await sut.resumeSession()
        }
    }

    @Test
    func test_resumeSession_offlineWallet_firebaseNetworkError() async throws {
        MockURLProtocol.clear()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let client = NetworkClient(configuration: configuration)
        let mockAppIntegrityProvider = MockAppIntegrityProvider()
        client.clientAttestationProvider = mockAppIntegrityProvider
        client.dPoPProvider = mockAppIntegrityProvider
        
        // GIVEN I am a returning user with local auth enabled and tokens stored
        let refreshTokenExchangeManager = RefreshTokenExchangeManager(networkClient: client)
        let sut: PersistentSessionManager = try .makeForResumeSession(mockRefreshTokenExchangeManager: refreshTokenExchangeManager)
        
        // AND I have no internet
        mockAppIntegrityProvider.errorThrownAssertingIntegrity = FirebaseAppCheckError(.network, reason: "test")
        
        // WHEN I attempt to resume my session
        await #expect(throws: Networking.AppIntegrityError.self) {
            try await sut.resumeSession()
        }
    }
    
    @Test
    func test_resumeSession_refreshTokenExchange_restoresUserAndAccessToken() async throws {
        // GIVEN I am a returning user with tokens stored
        let mockAccessControlEncryptedStore = MockSecureStoreService()
        let mockEncryptedStore = MockSecureStoreService()
        let mockUnprotectedStore = MockDefaultsStore()
        let sut: PersistentSessionManager = try .makeForResumeSession(mockAccessControlEncryptedSecureStoreMigrator: mockAccessControlEncryptedStore,
                                                                      mockEncryptedStore: mockEncryptedStore,
                                                                      mockUnprotectedStore: mockUnprotectedStore)

        // WHEN I return to the app and authenticate successfully
        try await sut.resumeSession()
        
        // THEN my user session data is repopulated
        #expect(sut.user.value?.persistentID == "af835f3a-b3f1-4b50-b3db-88c185eae46b")
        #expect(sut.walletStoreID == "LpyvURud63e1LDVO0AEf7AJvXUrFlCGRfF-tl63vUe0")
        #expect(sut.user.value?.email == "mock@email.com")
        
        // AND my refresh token expiry date is saved
        #expect(try mockEncryptedStore.readItem(itemName: OLString.refreshTokenExpiry) == "1772632425.0")
        
        // AND my tokens are saved
        let tokens = StoredTokens.encodeKeys(
            idToken: MockJWTs.genericToken,
            refreshToken: MockJWTs.genericToken,
            accessToken: MockJWTs.genericToken
        )
        #expect(try mockAccessControlEncryptedStore.readItem(itemName: OLString.storedTokens) == tokens)
       
        // AND the token provider access token is updated
        #expect(sut.tokenProvider.accessToken == MockJWTs.genericToken)
        
        // AND my access token expiry is updated
        let expiryDate = mockUnprotectedStore.value(forKey: OLString.accessTokenExpiry) as? Date
        #expect(expiryDate?.timeIntervalSince1970.description == "64092211200.0")
    }
    
    @Test
    func test_resumeSession_withoutRefreshToken() async throws {
        let mockAccessControlEncryptedStore = MockSecureStoreService()
        let mockLocalAuthentication = MockLocalAuthManager()
        let mockEncryptedStore = MockSecureStoreService()
        let mockUnprotectedStore = MockDefaultsStore()
        let sut: PersistentSessionManager = try .makeWithMocks(mockAccessControlEncryptedSecureStoreMigrator: mockAccessControlEncryptedStore,
                                                               mockEncryptedStore: mockEncryptedStore,
                                                               mockUnprotectedStore: mockUnprotectedStore,
                                                               mockLocalAuthentication: mockLocalAuthentication)

        // GIVEN I am a returning user with local auth enabled
        mockLocalAuthentication.localAuthIsEnabledOnTheDevice = true
        mockUnprotectedStore.savedData = [OLString.returningUser: true]
        
        // AND I have a persistentSessionID saved in secure store
        try mockEncryptedStore.saveItem(
            item: UUID().uuidString,
            itemName: OLString.persistentSessionID
        )
        
        // AND I have no refresh token saved in secure store
        let data = StoredTokens.encodeKeys(
            idToken: MockJWTs.genericToken,
            refreshToken: nil,
            accessToken: MockJWTs.genericToken
        )
        try mockAccessControlEncryptedStore.saveItem(
            item: data,
            itemName: OLString.storedTokens
        )
        
        // WHEN I return to the app and authenticate successfully
        try await sut.resumeSession()
        
        // THEN my user session data is repopulated
        #expect(sut.user.value?.persistentID == "af835f3a-b3f1-4b50-b3db-88c185eae46b")
        #expect(sut.walletStoreID == "LpyvURud63e1LDVO0AEf7AJvXUrFlCGRfF-tl63vUe0")
        #expect(sut.user.value?.email == "mock@email.com")
        
        // AND the token provider access token is updated
        #expect(sut.tokenProvider.accessToken == MockJWTs.genericToken)
        
        // AND no refresh token expiry date is saved
        do {
            _ = try mockEncryptedStore.readItem(itemName: OLString.refreshTokenExpiry)
        } catch {
            if error.kind == .unableToRetrieveFromUserDefaults {
                // Expected path
            }
        }
    }

    @Test
    func test_endCurrentSession_clearsDataFromSession() async throws {
        let mockAccessControlEncryptedStore = MockSecureStoreService()
        let sut: PersistentSessionManager = try .makeForResumeSession(mockAccessControlEncryptedSecureStoreMigrator: mockAccessControlEncryptedStore)

        try await sut.resumeSession()
        // WHEN I end the session
        sut.endCurrentSession()
        // THEN my data is cleared
        #expect(sut.tokenProvider.accessToken == nil)
        #expect(sut.user.value == nil)
        
        #expect(mockAccessControlEncryptedStore.savedItems == [:])
    }
    
    @Test
    func test_endCurrentSession_clearsAllPersistedData() async throws {
        let mockAccessControlEncryptedStore = MockSecureStoreService()
        let mockEncryptedStore = MockSecureStoreService()
        let mockUnprotectedStore = MockDefaultsStore()
        let sut: PersistentSessionManager = try .makeWithMocks(mockAccessControlEncryptedSecureStoreMigrator: mockAccessControlEncryptedStore,
                                                               mockEncryptedStore: mockEncryptedStore,
                                                               mockUnprotectedStore: mockUnprotectedStore)

        // GIVEN I have an access token expiry stored
        mockUnprotectedStore.savedData = [
            OLString.returningUser: true,
            OLString.accessTokenExpiry: Date.distantPast
        ]
        // AND a persistentSessionID stored
        try mockEncryptedStore.saveItem(item: UUID().uuidString, itemName: OLString.persistentSessionID)
        
        // AND tokens stored
        let data = StoredTokens.encodeKeys(
            idToken: MockJWTs.genericToken,
            refreshToken: MockJWTs.genericToken,
            accessToken: MockJWTs.genericToken
        )
        try mockAccessControlEncryptedStore.saveItem(
            item: data,
            itemName: OLString.storedTokens
        )
        
        sut.registerSessionBoundData([
            mockUnprotectedStore,
            mockAccessControlEncryptedStore,
            mockEncryptedStore
        ])
        
        // WHEN I clear all session data
        try await sut.clearAllSessionData(presentSystemLogOut: true)
        
        // THEN my session data is deleted
        #expect(mockUnprotectedStore.savedData.count == 0)
        #expect(mockEncryptedStore.savedItems == [:])
        #expect(mockAccessControlEncryptedStore.savedItems == [:])
    }
    
    @Test
    func test_resumeSession_withoutRefreshToken_butWithRefreshTokenSavedInEncryptedStore() async throws {
        // GIVEN I am a returning user with a refresh token stored
        let mockEncryptedStore = MockSecureStoreService()
        let sut: PersistentSessionManager = try .makeForResumeSession(mockEncryptedStore: mockEncryptedStore,
                                                                      mockRefreshTokenExchangeManager: MockRefreshTokenNilExchangeManager())
        
        // GIVEN my refresh token is expired
        try mockEncryptedStore.saveItem(
            item: Date.distantPast.timeIntervalSince1970.description,
            itemName: OLString.refreshTokenExpiry
        )
        // THEN the session is not valid
        #expect(sut.isSessionValid == false)
        #expect(sut.sessionState == .expired)
                
        // WHEN I return to the app and authenticate successfully but without a refresh token
        try await sut.resumeSession()
        
        // THEN the old refresh Token Expiry should not be present in the encrypted store
        #expect(mockEncryptedStore.savedItems.keys.contains(OLString.refreshTokenExpiry) == false)
    }
    
    @Test
    func test_startSession_withoutRefreshToken_butWithRefreshTokenSavedInEncryptedStore() async throws {
        let mockEncryptedStore = MockSecureStoreService()
        let mockUnprotectedStore = MockDefaultsStore()
        let sut: PersistentSessionManager = try .makeWithMocks(mockEncryptedStore: mockEncryptedStore,
                                                               mockUnprotectedStore: mockUnprotectedStore)

        // GIVEN I am a returning user
        mockUnprotectedStore.savedData = [OLString.returningUser: true]
        let persistentSessionID = UUID().uuidString
        try mockEncryptedStore.saveItem(
            item: persistentSessionID,
            itemName: OLString.persistentSessionID
        )
        
        // GIVEN my refresh token is expired
        try mockEncryptedStore.saveItem(
            item: Date.distantPast.timeIntervalSince1970.description,
            itemName: OLString.refreshTokenExpiry
        )
        
        // WHEN I re-authenticate
        try await sut.startAuthSession(
            MockLoginSessionNoRefresh(window: UIWindow()),
            using: MockLoginSessionConfiguration.oneLoginSessionConfiguration
        )
        // THEN there's no refresh token expiry in the store anymore
        #expect(mockEncryptedStore.savedItems == [
                OLString.persistentSessionID: "af835f3a-b3f1-4b50-b3db-88c185eae46b"
            ]
        )
    }
    
    @Test
    func test_refreshTokenExchange_isSerialisedAcrossResumeSessionAndAuthorizedRequest() async throws {
        // GIVEN I am a returning user with a refresh token stored
        let mockRefreshTokenExchangeManager = MockRefreshTokenExchangeManagerGuarantor()
        let sut: PersistentSessionManager = try .makeForResumeSession(mockRefreshTokenExchangeManager: mockRefreshTokenExchangeManager)
        
        let numberOfTasks = 10
        await withTaskGroup { group in
            for _ in 1...numberOfTasks {
                group.addTask {
                    do {
                        try await sut.resumeSession()
                    } catch let error as MockRefreshTokenExchangeManagerGuarantor.GetUpdatedTokensError {
                        Issue.record("Thrown Error with description \(String(describing: error)) - \(error.failureReason) associated with: \(error)")
                    } catch {
                        Issue.record("Thrown Error with description \(String(describing: error)) associated with: \(error)")
                    }
                }
            }
        }
        
        #expect(mockRefreshTokenExchangeManager.capturedRefreshTokens.count == numberOfTasks)
    }
    
    @Test(
        """
        ON THE CONDITION a SecureStoreService throws a SecureStoreError(.cantDecryptData)
        AND a returning user
        GIVEN a PersistentSessionManager
        WHEN calling `assertReturningUserCanLogin()`
        THEN a SecureStoreError(.cantDecryptData) is thrown
        AND the user session data is cleared
        AND a `.systemLogUserOut` notification has been posted
        """
    )
    func assertReturningUserCanLoginClearsReturningUserAndThrowsOriginalError() async throws {
        let cantDecryptDataError = SecureStoreError(
            .cantDecryptData,
            originalError: NSError(domain: NSOSStatusErrorDomain, code: -50)
        )
        let encryptedStore = MockSecureStoreService()
        encryptedStore.readItemAsFunction = MockSecureStoreService.errorFromReadItem(cantDecryptDataError)
        
        let systemLogOutNotifications = NotificationCenter.default.notifications(named: .systemLogUserOut)
        let systemLogOutIterator = systemLogOutNotifications.makeAsyncIterator()
        
        let mockUnprotectedStore = MockDefaultsStore.returningUser()
        let mockAnalyticsPreferenceStore = MockAnalyticsPreferenceStore()
        let (mockWalletSessionBound, walletData) = WalletSessionBoundDataStub.stubWalletData(["any": "value"])
        mockAnalyticsPreferenceStore.hasAcceptedAnalytics = true
        let sut = try PersistentSessionManager.makeWithMocks(mockEncryptedStore: encryptedStore,
                                                             mockUnprotectedStore: mockUnprotectedStore,
                                                             mockWalletSessionData: mockWalletSessionBound,
                                                             mockAnalyticsPreferenceStore: mockAnalyticsPreferenceStore
        )

        let error = await #expect(throws: SecureStoreError.self) {
            try await sut.assertReturningUserCanLogin()
        }

        #expect(error?.kind == .cantDecryptData)

        #expect(encryptedStore.savedItems.isEmpty)
        #expect(mockUnprotectedStore.savedData.isEmpty)
        #expect(walletData.isEmpty)
        #expect(mockAnalyticsPreferenceStore.hasAcceptedAnalytics == false)
        
        #expect(!sut.isReturningUser)
        #expect(await systemLogOutIterator.next() == Notification(name: .systemLogUserOut))
    }

    @Test
    func assertReturningUserCanLoginIsEvaluatedOnlyOnce() async throws {
        let (mockEncryptedStore, mockEncryptedStoreReadItem) = MockSecureStoreService.mockReadItemCounter()
        try mockEncryptedStore.saveItem(
            item: UUID().uuidString,
            itemName: OLString.persistentSessionID
        )
        
        let sut = try PersistentSessionManager.makeWithMocks(mockEncryptedStore: mockEncryptedStore,
                                                             mockUnprotectedStore: MockDefaultsStore.returningUser())

        try await sut.assertReturningUserCanLogin()
        try await sut.assertReturningUserCanLogin()

        #expect(mockEncryptedStoreReadItem.count == 1)
    }

    @Test
    func assertfirstTimeUserDoesNotReadEncryptedStore() async throws {
        let (mockEncryptedStore, mockEncryptedStoreReadItem) = MockSecureStoreService.mockReadItemCounter()
        
        let mockUnprotectedStore = MockDefaultsStore.firstTimeUser()
        let sut = try PersistentSessionManager.makeWithMocks(mockEncryptedStore: mockEncryptedStore,
                                                             mockUnprotectedStore: mockUnprotectedStore)

        try await sut.assertReturningUserCanLogin()

        #expect(!mockEncryptedStoreReadItem.called())
    }

    @Test("Wallet deletion warnings are logged")
    func clearAllSessionDataLogsWalletDeletionWarnings() async throws {
        let warnings = [
            WalletStoreError(.updateDocumentExpiryDate),
            WalletStoreError(.updateValid)
        ]

        func deleteReturnsErrors() async throws(WalletStoreError) -> [WalletStoreError] {
            return warnings
        }

        let analyticsService = MockAnalyticsService()
        let walletSessionData = WalletSessionData(
            walletSDK: MockWalletSDKWrapper(deleteAsFunction: deleteReturnsErrors)
        )
        let sut = try PersistentSessionManager.makeWithMocks(mockAnalyticsService: analyticsService,
                                                             mockWalletSessionData: walletSessionData)

        try await sut.clearAllSessionData(presentSystemLogOut: false)

        #expect(analyticsService.crashesLogged == warnings.map { $0 as NSError })
    }

    @Test("No crash logs for no wallet deletion warnings")
    func clearAllSessionDataWithNoWalletDeletionWarnings() async throws {
        let analyticsService = MockAnalyticsService()
        let walletSessionData = WalletSessionData(
            walletSDK: MockWalletSDKWrapper(deleteAsFunction: {
                return []
            })
        )
        let sut = try PersistentSessionManager.makeWithMocks(mockAnalyticsService: analyticsService,
                                                             mockWalletSessionData: walletSessionData)

        try await sut.clearAllSessionData(presentSystemLogOut: false)

        #expect(analyticsService.crashesLogged.isEmpty)
    }

    @Test("Critical wallet deletion error is propagated")
    func clearAllSessionDataPropagatesCriticalWalletDeletionError() async throws {
        let expectedError = WalletStoreError(.walletUnsafeState)
        
        func deleteThrowsWalletUnsafeState() async throws(WalletStoreError) -> [WalletStoreError] {
            throw expectedError
        }

        let analyticsService = MockAnalyticsService()
        let walletSessionData = WalletSessionData(
            walletSDK: MockWalletSDKWrapper(deleteAsFunction: deleteThrowsWalletUnsafeState)
        )
        let sut = try PersistentSessionManager.makeWithMocks(mockAnalyticsService: analyticsService,
                                                             mockWalletSessionData: walletSessionData)

        let error = await #expect(throws: WalletStoreError.self) {
            try await sut.clearAllSessionData(presentSystemLogOut: false)
        }

        #expect(error?.kind == expectedError.kind)
        #expect(analyticsService.crashesLogged.isEmpty)
    }
    
    /// This is a case of a call to `resumeSession()` when retrieving the encryptor throws an error,
    /// which asserts that a refresh token reuse error is not recorded (i.e. happens).
    ///
    /// In other words, no refresh token exchange occurs, when an error occurs while attempting to
    /// resume the user session.
    @Test(
        """
        ON THE CONDITION a SecureStoreService `encryptor`
            throws a SecureStoreError(.cantRetrieveKey, originalError: errSecInteractionNotAllowed)
        GIVEN a PersistentSessionManager
        OF a returning user with stored tokens, who is "NOT enrolling" and "NOT authenticated" due to a `nil` `expiryDate`
        WHEN calling `resumeSession()`
        THEN a SecureStoreError(.cantRetrieveKey) is thrown
        AND the `refreshTokenExchangeManager` received no refresh token
        """,
        .bug("https://govukverify.atlassian.net/browse/DCMAW-21354"))
    func expect_refreshToken_notExchanged_given_keyInteractionNotAllowed_when_resumeSession() async throws {
        let mockAccessControlEncryptedStore: MockSecureStoreService = try .makeWithStoredTokens()
        let mockRefreshTokenExchangeManager = MockRefreshTokenExchangeManagerGuarantor()
        
        let sut: PersistentSessionManager = try .makeReturningNonEnrollingUnauthenticatedUserWithoutSavedExpiryDate(
                                                    accessControlEncryptedSecureStoreMigrator: mockAccessControlEncryptedStore,
                                                    refreshTokenExchangeManager: mockRefreshTokenExchangeManager)
        
        let interactionNotAllowed = NSError(
            domain: NSOSStatusErrorDomain,
            code: Int(errSecInteractionNotAllowed)
        )
        mockAccessControlEncryptedStore.encryptorAsFunction = MockSecureStoreService.errorFromEncryptorAsFunction(
            error: SecureStoreError(.cantRetrieveKey, originalError: interactionNotAllowed)
        )
        
        let error = await #expect(throws: SecureStoreError.self) {
            do {
                try await sut.resumeSession()
            } catch let error as MockRefreshTokenExchangeManagerGuarantor.GetUpdatedTokensError {
                Issue.record(error)
            }
        }
        
        #expect(error?.kind == .cantRetrieveKey)
        #expect(mockRefreshTokenExchangeManager.capturedRefreshTokens.count == 0)
    }

    @Test(
        """
        GIVEN a PersistentSessionManager
        OF a returning user with stored tokens, who is "NOT enrolling" and "NOT authenticated" due to a `nil` `expiryDate`
        WHEN calling `resumeSession()`
        AND the `refreshTokenExchangeManager` received a refresh token
        """,
        .bug("https://govukverify.atlassian.net/browse/DCMAW-21354"))
    func expect_refreshToken_exchanged_when_resumeSession() async throws {
        let mockAccessControlEncryptedStore: MockSecureStoreService = try .makeWithStoredTokens()
        let mockRefreshTokenExchangeManager = MockRefreshTokenExchangeManagerGuarantor()

        let sut: PersistentSessionManager = try .makeReturningNonEnrollingUnauthenticatedUserWithoutSavedExpiryDate(
                                                    accessControlEncryptedSecureStoreMigrator: mockAccessControlEncryptedStore,
                                                    refreshTokenExchangeManager: mockRefreshTokenExchangeManager)
        
        do {
            try await sut.resumeSession()
        } catch let error as MockRefreshTokenExchangeManagerGuarantor.GetUpdatedTokensError {
            Issue.record(error)
        }

        #expect(mockRefreshTokenExchangeManager.capturedRefreshTokens.count == 1)
    }
}
// swiftlint:enable type_body_length
