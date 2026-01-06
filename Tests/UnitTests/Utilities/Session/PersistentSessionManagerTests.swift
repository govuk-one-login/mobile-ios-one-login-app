// swiftlint:disable file_length
import AppIntegrity
import Authentication
@testable import Logging
import MockNetworking
import Networking
@testable @preconcurrency import OneLogin
import SecureStore
import XCTest

final class PersistentSessionManagerTests: XCTestCase {
    private var mockAccessControlEncryptedStore: MockSecureStoreService!
    private var mockEncryptedStore: MockSecureStoreService!
    private var mockUnprotectedStore: MockDefaultsStore!
    private var mockLocalAuthentication: MockLocalAuthManager!
    private var mockRefreshTokenExchangeManager: MockRefreshTokenExchangeManager!
    private var mockStoredTokens: StoredTokens!
    private var sut: PersistentSessionManager!
    
    private var didCall_deleteSessionBoundData = false
    
    @MainActor
    override func setUp() {
        super.setUp()
        
        mockAccessControlEncryptedStore = MockSecureStoreService()
        mockEncryptedStore = MockSecureStoreService()
        mockUnprotectedStore = MockDefaultsStore()
        mockLocalAuthentication = MockLocalAuthManager()
        mockRefreshTokenExchangeManager = MockRefreshTokenExchangeManager()
        
        sut = PersistentSessionManager(
            accessControlEncryptedStore: mockAccessControlEncryptedStore,
            encryptedStore: mockEncryptedStore,
            unprotectedStore: mockUnprotectedStore,
            localAuthentication: mockLocalAuthentication
        )
    }
    
    override func tearDown() {
        AppEnvironment.updateFlags(
            releaseFlags: [:],
            featureFlags: [:]
        )
        
        mockAccessControlEncryptedStore = nil
        mockEncryptedStore = nil
        mockUnprotectedStore = nil
        mockLocalAuthentication = nil
        mockRefreshTokenExchangeManager = nil
        mockStoredTokens = nil
        sut = nil
        
        didCall_deleteSessionBoundData = false
        
        super.tearDown()
    }
}

extension PersistentSessionManagerTests {
    func test_initialState() {
        XCTAssertNil(sut.expiryDate)
        XCTAssertFalse(sut.isSessionValid)
        XCTAssertFalse(sut.isReturningUser)
        XCTAssertFalse(sut.isEnrolling)
        XCTAssertEqual(sut.sessionState, .nonePresent)
    }
    
    func test_sessionExpiryDate_refreshToken() throws {
        // GIVEN the encrypted store contains a refresh token expiry date
        let date = Date.distantFuture
        try mockEncryptedStore.saveItem(
            item: date.timeIntervalSince1970.description,
            itemName: OLString.refreshTokenExpiry
        )
        // THEN it is exposed by the session manager
        XCTAssertEqual(sut.expiryDate, date.withFifteenSecondBuffer)
    }
    
    func test_sessionExpiryDate_bothTokensSet() throws {
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
        XCTAssertEqual(sut.expiryDate, refreshTokenExpiryDate.withFifteenSecondBuffer)
    }
    
    func test_sessionExpiryDate_accessToken() {
        // GIVEN the unprotected store contains an access token expiry date
        let date = Date()
        mockUnprotectedStore.set(
            date,
            forKey: OLString.accessTokenExpiry
        )
        // THEN it is exposed by the session manager
        XCTAssertEqual(sut.expiryDate, date.withFifteenSecondBuffer)
    }
    
    func test_sessionIsValid_refreshToken_notExpired() throws {
        // GIVEN the unprotected store contains a refresh token expiry date in the future
        try mockEncryptedStore.saveItem(
            item: Date.distantFuture.timeIntervalSince1970.description,
            itemName: OLString.refreshTokenExpiry
        )
        
        // THEN the session is valid
        XCTAssertTrue(sut.isSessionValid)
        XCTAssertEqual(sut.sessionState, .saved)
    }
    
    func test_sessionIsValid_accessToken_notExpired() {
        // GIVEN the unprotected store contains an access token expiry date in the future
        mockUnprotectedStore.set(
            Date.distantFuture,
            forKey: OLString.accessTokenExpiry
        )
        // THEN the session is valid
        XCTAssertTrue(sut.isSessionValid)
        XCTAssertEqual(sut.sessionState, .saved)
    }
    
    func test_sessionIsInvalid_refreshToken_Expired() throws {
        // GIVEN the unprotected store contains a refresh token expiry date in the past
        try mockEncryptedStore.saveItem(
            item: Date.distantPast.timeIntervalSince1970.description,
            itemName: OLString.refreshTokenExpiry
        )
        // THEN the session is not valid
        XCTAssertFalse(sut.isSessionValid)
        XCTAssertEqual(sut.sessionState, .expired)
    }
    
    func test_sessionIsInvalid_accessToken_Expired() {
        // GIVEN the unprotected store contains an access token expiry date in the past
        mockUnprotectedStore.set(
            Date.distantPast,
            forKey: OLString.accessTokenExpiry
        )
        // THEN the session is not valid
        XCTAssertFalse(sut.isSessionValid)
        XCTAssertEqual(sut.sessionState, .expired)
    }
    
    func test_isAccessTokenValid() {
        // GIVEN the unprotected store contains an access token expiry date in the future
        mockUnprotectedStore.set(
            Date.distantFuture,
            forKey: OLString.accessTokenExpiry
        )
        // THEN the session is not valid
        XCTAssertTrue(sut.isAccessTokenValid)
    }
    
    func test_isAccessTokenValid_expired() {
        // GIVEN the unprotected store contains an access token expiry date in the past
        mockUnprotectedStore.set(
            Date.distantPast,
            forKey: OLString.accessTokenExpiry
        )
        // THEN the session is not valid
        XCTAssertFalse(sut.isAccessTokenValid)
    }
    
    func test_returnRefreshTokenIfValid() throws {
        // GIVEN the unprotected store contains an access token expiry date in the future
        try mockEncryptedStore.saveItem(
            item: Date.distantFuture.timeIntervalSince1970.description,
            itemName: OLString.refreshTokenExpiry
        )
        
        // AND a refresh token is stored
        let data = encodeKeys(
            idToken: MockJWTs.genericToken,
            refreshToken: MockJWTs.genericToken,
            accessToken: MockJWTs.genericToken
        )
        try mockAccessControlEncryptedStore.saveItem(
            item: data,
            itemName: OLString.storedTokens
        )
        
        // THEN a refresh token is returned
        XCTAssertEqual(try sut.validTokensForRefreshExchange?.refreshToken, MockJWTs.genericToken)
        XCTAssertEqual(try sut.validTokensForRefreshExchange?.idToken, MockJWTs.genericToken)
    }
    
    func test_returnRefreshTokenIfValid_expired() throws {
        // GIVEN the unprotected store contains an access token expiry date in the past
        try mockEncryptedStore.saveItem(
            item: Date.distantPast.timeIntervalSince1970.description,
            itemName: OLString.refreshTokenExpiry
        )
        
        // AND a refresh token is stored
        let data = encodeKeys(
            idToken: MockJWTs.genericToken,
            refreshToken: MockJWTs.genericToken,
            accessToken: MockJWTs.genericToken
        )
        try mockAccessControlEncryptedStore.saveItem(
            item: data,
            itemName: OLString.storedTokens
        )
        
        // THEN no refresh token is returned
        XCTAssertNil(try sut.validTokensForRefreshExchange)
    }
    
    func test_isReturningUserPullsFromStore() {
        mockUnprotectedStore.set(
            true,
            forKey: OLString.returningUser
        )
        XCTAssertTrue(sut.isReturningUser)
    }
    
    func test_persistentID() throws {
        try mockEncryptedStore.saveItem(
            item: "123456789",
            itemName: OLString.persistentSessionID
        )
        XCTAssertEqual(sut.persistentID, "123456789")
    }
    
    func test_persistentID_nil() throws {
        XCTAssertNil(sut.persistentID)
    }
    
    func test_persistentID_empty() throws {
        try mockEncryptedStore.saveItem(
            item: "",
            itemName: OLString.persistentSessionID
        )
        XCTAssertNil(sut.persistentID)
    }
    
    func test_hasNotRemovedLocalAuth() throws {
        mockLocalAuthentication.localAuthIsEnabledOnTheDevice = true
        mockUnprotectedStore.set(
            true,
            forKey: OLString.returningUser
        )
        XCTAssertTrue(hasNotRemovedLocalAuth)
    }
    
    func test_hasRemovedLocalAuth() throws {
        mockLocalAuthentication.localAuthIsEnabledOnTheDevice = false
        mockUnprotectedStore.set(
            true,
            forKey: OLString.returningUser
        )
        XCTAssertFalse(hasNotRemovedLocalAuth)
    }
    
    func test_hasRemovedLocalAuth_inverse() throws {
        mockLocalAuthentication.localAuthIsEnabledOnTheDevice = true
        mockUnprotectedStore.set(
            false,
            forKey: OLString.returningUser
        )
        XCTAssertFalse(hasNotRemovedLocalAuth)
    }
    
    @MainActor
    func test_startSession_logsTheUserIn() async throws {
        // GIVEN I am not logged in
        let loginSession = MockLoginSession(window: UIWindow())
        // WHEN I start a session
        try await sut.startAuthSession(
            loginSession,
            using: MockLoginSessionConfiguration.oneLoginSessionConfiguration
        )
        // THEN a login screen is shown
        XCTAssertTrue(loginSession.didCallPerformLoginFlow)
        // AND no persistent session ID is provided
        let configuration = try XCTUnwrap(loginSession.sessionConfiguration)
        XCTAssertEqual(configuration.persistentSessionId, "123456789")
        XCTAssertEqual(sut.sessionState, .oneTime)
    }
    
    @MainActor
    func test_startSession_logsTheUserIn_appIntegrity() async throws {
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
        XCTAssertTrue(loginSession.didCallPerformLoginFlow)
        // AND no persistent session ID is provided
        let tokenHeaders = try await loginSession.sessionConfiguration?.tokenHeaders()
        let tokenParameters = try await loginSession.sessionConfiguration?.tokenParameters()
        XCTAssertNil(tokenHeaders)
        XCTAssertNil(tokenParameters)
    }
    
    @MainActor
    func test_startSession_cannotReauthenticateWithoutPersistentSessionID() async throws {
        let mockAnalyticsPrefernceStore = UserDefaultsPreferenceStore()
        mockAnalyticsPrefernceStore.hasAcceptedAnalytics = true
        
        let exp = XCTNSNotificationExpectation(
            name: .systemLogUserOut,
            object: nil,
            notificationCenter: NotificationCenter.default
        )
        // GIVEN I am a returning user
        mockUnprotectedStore.set(
            true,
            forKey: OLString.returningUser
        )
        sut.registerSessionBoundData([
            self,
            mockEncryptedStore,
            mockUnprotectedStore,
            mockAnalyticsPrefernceStore
        ])
        // AND I am unable to re-authenticate because I have no persistent session ID
        mockEncryptedStore.deleteItem(itemName: OLString.persistentSessionID)
        // WHEN I start a session
        do {
            try await sut.startAuthSession(
                MockLoginSession(window: UIWindow()),
                using: MockLoginSessionConfiguration.oneLoginSessionConfiguration
            )
            XCTFail("Expected a sessionMismatch error to be thrown")
        } catch PersistentSessionError.sessionMismatch {
            // THEN a session mismatch error is thrown
            // AND my session data is cleared
            XCTAssertTrue(didCall_deleteSessionBoundData)
            XCTAssertTrue(mockEncryptedStore.savedItems.isEmpty)
            XCTAssertTrue(mockUnprotectedStore.savedData.isEmpty)
            XCTAssertNil(mockAnalyticsPrefernceStore.hasAcceptedAnalytics)
            // AND a logout notification is sent
            await fulfillment(of: [exp], timeout: 5)
        } catch {
            XCTFail("Unexpected error was thrown")
        }
    }
    
    @MainActor
    func test_startSession_clearAppForLogin_exceptAnalyticsPreference() async throws {
        let mockAnalyticsPrefernceStore = UserDefaultsPreferenceStore()
        mockAnalyticsPrefernceStore.hasAcceptedAnalytics = true
        
        // GIVEN I am a returning user who previously accepted analytics
        sut.registerSessionBoundData([
            self,
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
        
        // THEN my session data is cleared
        waitForTruth(self.didCall_deleteSessionBoundData, timeout: 5)
        XCTAssertTrue(mockEncryptedStore.savedItems.isEmpty)
        XCTAssertTrue(mockUnprotectedStore.savedData.isEmpty)
        
        // AND my analytics preference is still set
        XCTAssertEqual(mockAnalyticsPrefernceStore.hasAcceptedAnalytics, true)
    }
    
    @MainActor
    func test_startSession_exposesUserAndAccessToken() async throws {
        // GIVEN I am logged in
        // WHEN I start a session
        try await sut.startAuthSession(
            MockLoginSession(window: UIWindow()),
            using: MockLoginSessionConfiguration.oneLoginSessionConfiguration
        )
        // THEN my User details
        XCTAssertEqual(sut.user.value?.persistentID, "1d003342-efd1-4ded-9c11-32e0f15acae6")
        XCTAssertEqual(sut.user.value?.email, "mock@email.com")
        // AND access token are populated
        XCTAssertEqual(sut.tokenProvider.subjectToken, "accessTokenResponse")
    }
    
    @MainActor
    func test_startSession_skipsSavingTokensForNewUsers() async throws {
        // GIVEN I am not logged in
        // WHEN I start a session
        try await sut.startAuthSession(
            MockLoginSession(window: UIWindow()),
            using: MockLoginSessionConfiguration.oneLoginSessionConfiguration
        )
        // THEN my session data is not saved
        XCTAssertEqual(mockEncryptedStore.savedItems, [:])
        XCTAssertEqual(mockUnprotectedStore.savedData.count, 0)
    }
    
    @MainActor
    func test_startSession_savesTokensForReturningUsers() async throws {
        let exp = XCTNSNotificationExpectation(
            name: .enrolmentComplete,
            object: nil,
            notificationCenter: NotificationCenter.default
        )
        
        // GIVEN I am a returning user
        mockUnprotectedStore.savedData = [OLString.returningUser: true]
        let persistentSessionID = UUID().uuidString
        try mockEncryptedStore.saveItem(
            item: persistentSessionID,
            itemName: OLString.persistentSessionID
        )
        // WHEN I re-authenticate
        try await sut.startAuthSession(
            MockLoginSession(window: UIWindow()),
            using: MockLoginSessionConfiguration.oneLoginSessionConfiguration
        )
        // THEN my session data is updated in the store
        XCTAssertEqual(mockEncryptedStore.savedItems, [
                OLString.refreshTokenExpiry: "1719397758.0",
                OLString.persistentSessionID: "1d003342-efd1-4ded-9c11-32e0f15acae6"
            ]
        )
        XCTAssertEqual(mockUnprotectedStore.savedData.count, 2)
        // AND the user can be returned to where they left off
        await fulfillment(of: [exp], timeout: 5)
    }
    
    @MainActor
    func test_saveSession_enrolsLocalAuthenticationForNewUsers() async throws {
        // GIVEN I am a new user
        mockUnprotectedStore.savedData = [OLString.returningUser: false]
        // AND I have logged in
        try await sut.startAuthSession(
            MockLoginSession(window: UIWindow()),
            using: MockLoginSessionConfiguration.oneLoginSessionConfiguration
        )
        // WHEN I attempt to save my session
        try sut.saveAuthSession()
        // THEN my session data is updated in the store
        XCTAssertEqual(mockEncryptedStore.savedItems, [
            OLString.refreshTokenExpiry: "1719397758.0",
            OLString.persistentSessionID: "1d003342-efd1-4ded-9c11-32e0f15acae6"
        ])
        XCTAssertEqual(mockUnprotectedStore.savedData.count, 2)
    }
    
    @MainActor
    func test_saveSession_doesNotRefreshSecureStoreManager() async throws {
        // GIVEN I am a new user
        mockUnprotectedStore.savedData = [OLString.returningUser: false]
        try mockAccessControlEncryptedStore.saveItem(
            item: "storedTokens",
            itemName: OLString.storedTokens
        )
        // AND I have logged in
        try await sut.startAuthSession(
            MockLoginSession(window: UIWindow()),
            using: MockLoginSessionConfiguration.oneLoginSessionConfiguration
        )
        // WHEN I attempt to save my session
        try sut.saveAuthSession()
        // THEN the secure store manager is not refreshed
        XCTAssertFalse(mockAccessControlEncryptedStore.didCallClearSessionData)
        XCTAssertFalse(mockEncryptedStore.didCallClearSessionData)
        // THEN the session data is updated in the store
        XCTAssertEqual(mockEncryptedStore.savedItems, [
                OLString.refreshTokenExpiry: "1719397758.0",
                OLString.persistentSessionID: "1d003342-efd1-4ded-9c11-32e0f15acae6"
            ]
        )
        XCTAssertEqual(mockUnprotectedStore.savedData.count, 2)
    }
    
    func test_resumeSession_refreshTokenExchange_noLocalAuth() async throws {
        // GIVEN I am a returning user with local auth enabled and tokens stored
        try setUpNeededForResumeSession()
        
        // IF I disable local auth
        mockLocalAuthentication.localAuthIsEnabledOnTheDevice = false
        
        // WHEN I attempt to resume my session
        do {
            try await sut.resumeSession(tokenExchangeManager: mockRefreshTokenExchangeManager)
        } catch let error as PersistentSessionError {
            // THEN an error is catch
            XCTAssertEqual(error, .userRemovedLocalAuth)
        }
    }
    
    func test_hasNotRemovedLocalAuth_throwsError_whenPasscodeRemoved() async throws {
        // GIVEN I am a returning user with an active session
        mockUnprotectedStore.savedData = [
            OLString.returningUser: true,
            OLString.accessTokenExpiry: Date.distantFuture
        ]
        // WHEN remove my passcode
        mockLocalAuthentication.localAuthIsEnabledOnTheDevice = false
        
        do {
            try await sut.resumeSession(
                tokenExchangeManager: mockRefreshTokenExchangeManager
            )
            XCTFail("Expected local auth removed error")
        } catch let error as PersistentSessionError {
            XCTAssertTrue(error == PersistentSessionError.userRemovedLocalAuth)
        } catch {
            XCTFail("Expected local auth removed error")
        }
    }
    
    func test_resumeSession_refreshTokenExchange_noPersistentSessionID() async throws {
        // GIVEN I am a returning user with local auth enabled
        mockUnprotectedStore.set(
            true,
            forKey: OLString.returningUser
        )
        mockLocalAuthentication.localAuthIsEnabledOnTheDevice = true
        
        // AND I have no persistent session ID
        mockEncryptedStore.deleteItem(itemName: OLString.persistentSessionID)
        XCTAssertNil(sut.persistentID)
        
        // WHEN I attempt to resume my session
        do {
            try await sut.resumeSession(tokenExchangeManager: mockRefreshTokenExchangeManager)
        } catch let error as PersistentSessionError {
            XCTAssertEqual(error, .noSessionExists)
        }
    }
    
    func test_resumeSession_refreshTokenExchange_idTokenNotStored() async throws {
        // GIVEN I am a returning user with local auth enabled and tokens stored
        try setUpNeededForResumeSession()
        
        // IF the ID token is no longer stored
        let tokens = encodeKeys(
            idToken: "",
            refreshToken: "refreshToken",
            accessToken: "accessToken"
        )
        
        try mockAccessControlEncryptedStore.saveItem(
            item: tokens,
            itemName: OLString.storedTokens
        )
        // WHEN I attempt to resume my session
        do {
            try await sut.resumeSession(tokenExchangeManager: mockRefreshTokenExchangeManager)
        } catch let error as PersistentSessionError {
            // THEN an error is thrown
            XCTAssertEqual(error, .idTokenNotStored)
        }
    }
    
    func test_resumeSession_refreshTokenExchange_restoresUserAndAccessToken() async throws {
        // GIVEN I am a returning user with tokens stored
        try setUpNeededForResumeSession()
        
        // WHEN I return to the app and authenticate successfully
        try await sut.resumeSession(tokenExchangeManager: mockRefreshTokenExchangeManager)
        
        // THEN my user session data is repopulated
        XCTAssertEqual(sut.user.value?.persistentID, "1d003342-efd1-4ded-9c11-32e0f15acae6")
        XCTAssertEqual(sut.user.value?.email, "mock@email.com")
        
        // AND my refresh token expiry date is saved
        XCTAssertEqual(try mockEncryptedStore.readItem(itemName: OLString.refreshTokenExpiry), "1719397758.0")
        
        // AND my tokens are saved
        let tokens = encodeKeys(
            idToken: MockJWTs.genericToken,
            refreshToken: MockJWTs.genericToken,
            accessToken: MockJWTs.genericToken
        )
        XCTAssertEqual(try mockAccessControlEncryptedStore.readItem(itemName: OLString.storedTokens), tokens)
       
        // AND the token provider access token is updated
        XCTAssertEqual(sut.tokenProvider.subjectToken, MockJWTs.genericToken)
        
        // AND my access token expiry is updated
        let expiryDate = mockUnprotectedStore.value(forKey: OLString.accessTokenExpiry) as? Date
        XCTAssertEqual(expiryDate?.timeIntervalSince1970.description, "64092211200.0")
    }
    
    func test_resumeSession_withoutRefreshToken() async throws {
        // GIVEN I am a returning user with local auth enabled
        mockLocalAuthentication.localAuthIsEnabledOnTheDevice = true
        mockUnprotectedStore.savedData = [OLString.returningUser: true]
        
        // AND I have a persistentSessionID saved in secure store
        try mockEncryptedStore.saveItem(
            item: UUID().uuidString,
            itemName: OLString.persistentSessionID
        )
        
        // AND I have no refresh token saved in secure store
        let data = encodeKeys(
            idToken: MockJWTs.genericToken,
            refreshToken: nil,
            accessToken: MockJWTs.genericToken
        )
        try mockAccessControlEncryptedStore.saveItem(
            item: data,
            itemName: OLString.storedTokens
        )
        
        // WHEN I return to the app and authenticate successfully
        try await sut.resumeSession(tokenExchangeManager: mockRefreshTokenExchangeManager)
        
        // THEN my user session data is repopulated
        XCTAssertEqual(sut.user.value?.persistentID, "1d003342-efd1-4ded-9c11-32e0f15acae6")
        XCTAssertEqual(sut.user.value?.email, "mock@email.com")
        
        // AND the token provider access token is updated
        XCTAssertEqual(sut.tokenProvider.subjectToken, MockJWTs.genericToken)
        
        // AND no refresh token expiry date is saved
        do {
            _ = try mockEncryptedStore.readItem(itemName: OLString.refreshTokenExpiry)
        } catch let error as SecureStoreError {
            XCTAssertTrue(error.kind == .unableToRetrieveFromUserDefaults)
        }
    }

    func test_endCurrentSession_clearsDataFromSession() async throws {
        try setUpNeededForResumeSession()
        
        try await sut.resumeSession(tokenExchangeManager: mockRefreshTokenExchangeManager)
        // WHEN I end the session
        sut.endCurrentSession()
        // THEN my data is cleared
        XCTAssertNil(sut.tokenProvider.subjectToken)
        XCTAssertNil(sut.user.value)
        
        XCTAssertEqual(mockAccessControlEncryptedStore.savedItems, [:])
    }
    
    func test_endCurrentSession_clearsAllPersistedData() async throws {
        // GIVEN I have an access token expiry stored
        mockUnprotectedStore.savedData = [
            OLString.returningUser: true,
            OLString.accessTokenExpiry: Date.distantPast
        ]
        // AND a persistentSessionID stored
        mockEncryptedStore.savedItems = [
            OLString.persistentSessionID: UUID().uuidString
        ]
        // AND tokens stored
        let data = encodeKeys(
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
        XCTAssertEqual(mockUnprotectedStore.savedData.count, 0)
        XCTAssertEqual(mockEncryptedStore.savedItems, [:])
        XCTAssertEqual(mockAccessControlEncryptedStore.savedItems, [:])
    }
}

extension PersistentSessionManagerTests {
    var hasNotRemovedLocalAuth: Bool {
        mockLocalAuthentication.canUseAnyLocalAuth && sut.isReturningUser
    }
}

extension PersistentSessionManagerTests {
    private func encodeKeys(
        idToken: String,
        refreshToken: String?,
        accessToken: String
    ) -> String {
        mockStoredTokens = StoredTokens(
            idToken: idToken,
            refreshToken: refreshToken,
            accessToken: accessToken
        )
        
        var keysAsData = String()
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            keysAsData = try encoder.encode(mockStoredTokens).base64EncodedString()
        } catch {
            print("error")
        }
        return keysAsData
    }
    
    private func setUpNeededForResumeSession() throws {
        // GIVEN I am a returning user with local auth enabled
        mockLocalAuthentication.localAuthIsEnabledOnTheDevice = true
        mockUnprotectedStore.savedData = [OLString.returningUser: true]
        
        // AND I have a persistentSessionID saved in secure store
        try mockEncryptedStore.saveItem(
            item: UUID().uuidString,
            itemName: OLString.persistentSessionID
        )
        
        // AND I have tokens saved in secure store
        let data = encodeKeys(
            idToken: MockJWTs.genericToken,
            refreshToken: MockJWTs.genericToken,
            accessToken: MockJWTs.genericToken
        )
        try mockAccessControlEncryptedStore.saveItem(
            item: data,
            itemName: OLString.storedTokens
        )
    }
}

extension PersistentSessionManagerTests: SessionBoundData {
    func clearSessionData() {
        didCall_deleteSessionBoundData = true
    }
}
