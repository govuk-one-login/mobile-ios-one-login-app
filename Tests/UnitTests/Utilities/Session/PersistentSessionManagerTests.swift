// swiftlint:disable file_length
import Authentication
@testable @preconcurrency import OneLogin
import XCTest

final class PersistentSessionManagerTests: XCTestCase {
    private var mockAccessControlEncryptedSecureStoreManager: MockSecureStoreManager!
    private var mockEncryptedSecureStoreManager: MockSecureStoreManager!
    private var mockUnprotectedStore: MockDefaultsStore!
    private var mockLocalAuthentication: MockLocalAuthManager!
    private var mockStoredTokens: StoredTokens!
    private var sut: PersistentSessionManager!
    private var didCall_deleteSessionBoundData = false
    
    @MainActor
    override func setUp() {
        super.setUp()
        
        mockAccessControlEncryptedSecureStoreManager = MockSecureStoreManager()
        mockEncryptedSecureStoreManager = MockSecureStoreManager()
        mockUnprotectedStore = MockDefaultsStore()
        mockLocalAuthentication = MockLocalAuthManager()
        
        sut = PersistentSessionManager(
            accessControlEncryptedSecureStoreManager: mockAccessControlEncryptedSecureStoreManager,
            encryptedSecureStoreManager: mockEncryptedSecureStoreManager,
            unprotectedStore: mockUnprotectedStore,
            localAuthentication: mockLocalAuthentication
        )
    }
    
    override func tearDown() {
        AppEnvironment.updateFlags(
            releaseFlags: [:],
            featureFlags: [:]
        )
        
        mockAccessControlEncryptedSecureStoreManager = nil
        mockEncryptedSecureStoreManager = nil
        mockUnprotectedStore = nil
        mockLocalAuthentication = nil
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
        try mockEncryptedSecureStoreManager.saveItem(
            item: date.timeIntervalSince1970.description,
            itemName: OLString.refreshTokenExpiry
        )
        // THEN it is exposed by the session manager
        XCTAssertEqual(sut.expiryDate, date)
    }
    
    func test_sessionExpiryDate_accessToken() {
        // GIVEN the unprotected store contains an access token expiry date
        let date = Date()
        mockUnprotectedStore.set(
            date,
            forKey: OLString.accessTokenExpiry
        )
        // THEN it is exposed by the session manager
        XCTAssertEqual(sut.expiryDate, date)
    }
    
    func test_sessionIsValid_refreshToken_notExpired() throws {
        // GIVEN the unprotected store contains a refresh token expiry date in the future
        try mockEncryptedSecureStoreManager.saveItem(
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
    
    func test_isReturningUserPullsFromStore() {
        mockUnprotectedStore.set(true, forKey: OLString.returningUser)
        XCTAssertTrue(sut.isReturningUser)
    }
    
    func test_hasNotRemovedLocalAuth() throws {
        mockLocalAuthentication.localAuthIsEnabledOnTheDevice = true
        mockUnprotectedStore.set(true, forKey: OLString.returningUser)
        XCTAssertTrue(hasNotRemovedLocalAuth)
    }
    
    func test_hasRemovedLocalAuth() throws {
        mockLocalAuthentication.localAuthIsEnabledOnTheDevice = false
        mockUnprotectedStore.set(true, forKey: OLString.returningUser)
        XCTAssertFalse(hasNotRemovedLocalAuth)
    }
    
    func test_hasRemovedLocalAuth_inverse() throws {
        mockLocalAuthentication.localAuthIsEnabledOnTheDevice = true
        mockUnprotectedStore.set(false, forKey: OLString.returningUser)
        XCTAssertFalse(hasNotRemovedLocalAuth)
    }
    
    @MainActor
    func test_startSession_logsTheUserIn() async throws {
        // GIVEN I am not logged in
        let loginSession = MockLoginSession(window: UIWindow())
        // WHEN I start a session
        try await sut.startSession(
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
        try await sut.startSession(
            loginSession,
            using: MockLoginSessionConfiguration.oneLoginSessionConfiguration
        )
        // THEN a login screen is shown
        XCTAssertTrue(loginSession.didCallPerformLoginFlow)
        // AND no persistent session ID is provided
        let configuration = try XCTUnwrap(loginSession.sessionConfiguration)
        XCTAssertEqual(configuration.persistentSessionId, "123456789")
    }
    
    func test_startSession_cannotReauthenticateWithoutPersistentSessionID() async throws {
        let exp = XCTNSNotificationExpectation(
            name: .systemLogUserOut,
            object: nil,
            notificationCenter: NotificationCenter.default
        )
        
        // GIVEN I am a returning user
        mockUnprotectedStore.set(true, forKey: OLString.returningUser)
        sut.registerSessionBoundData([
            self,
            mockEncryptedStore,
            mockUnprotectedStore
        ])
        // AND I am unable to re-authenticate because I have no persistent session ID
        mockEncryptedSecureStoreManager.deleteItem(itemName: OLString.persistentSessionID)
        // WHEN I start a session
        do {
            let loginSession = await MockLoginSession(window: UIWindow())
            try await sut.startSession(
                loginSession,
                using: MockLoginSessionConfiguration.oneLoginSessionConfiguration
            )
            
            XCTFail("Expected a sessionMismatch error to be thrown")
        } catch PersistentSessionError.sessionMismatch {
            // THEN a session mismatch error is thrown
            // AND my session data is cleared
            XCTAssertTrue(mockUnprotectedStore.savedData.isEmpty)
            XCTAssertTrue(didCall_deleteSessionBoundData)
            // AND a logout notification is sent
            await fulfillment(of: [exp], timeout: 5)
        } catch {
            XCTFail("Unexpected error was thrown")
        }
    }
    
    func test_startSession_exposesUserAndAccessToken() async throws {
        // GIVEN I am logged in
        let loginSession = await MockLoginSession(window: UIWindow())
        // WHEN I start a session
        try await sut.startSession(
            loginSession,
            using: MockLoginSessionConfiguration.oneLoginSessionConfiguration
        )
        // THEN my User details
        XCTAssertEqual(sut.user.value?.persistentID, "1d003342-efd1-4ded-9c11-32e0f15acae6")
        XCTAssertEqual(sut.user.value?.email, "mock@email.com")
        // AND access token are populated
        XCTAssertEqual(sut.tokenProvider.subjectToken, "accessTokenResponse")
    }
    
    func test_startSession_skipsSavingTokensForNewUsers() async throws {
        // GIVEN I am not logged in
        let loginSession = await MockLoginSession(window: UIWindow())
        // WHEN I start a session
        try await sut.startSession(
            loginSession,
            using: MockLoginSessionConfiguration.oneLoginSessionConfiguration
        )
        // THEN my session data is not saved
        XCTAssertEqual(mockEncryptedSecureStoreManager.savedItems, [:])
        XCTAssertEqual(mockUnprotectedStore.savedData.count, 0)
    }
    
    func test_startSession_savesTokensForReturningUsers() async throws {
        let exp = XCTNSNotificationExpectation(
            name: .enrolmentComplete,
            object: nil,
            notificationCenter: NotificationCenter.default
        )
        
        // GIVEN I am a returning user
        mockUnprotectedStore.savedData = [OLString.returningUser: true]
        let persistentSessionID = UUID().uuidString
        try mockEncryptedSecureStoreManager.saveItem(
            item: persistentSessionID,
            itemName: OLString.persistentSessionID
        )
        // WHEN I re-authenticate
        let loginSession = await MockLoginSession(window: UIWindow())
        try await sut.startSession(
            loginSession,
            using: MockLoginSessionConfiguration.oneLoginSessionConfiguration
        )
        // THEN my session data is updated in the store
        XCTAssertEqual(mockEncryptedSecureStoreManager.savedItems, [OLString.refreshTokenExpiry: "1719397758.0",
                                                                    OLString.persistentSessionID: "1d003342-efd1-4ded-9c11-32e0f15acae6"])
        XCTAssertEqual(mockUnprotectedStore.savedData.count, 2)
        // AND the user can be returned to where they left off
        await fulfillment(of: [exp], timeout: 5)
    }
    
    func test_saveSession_enrolsLocalAuthenticationForNewUsers() async throws {
        // GIVEN I am a new user
        mockUnprotectedStore.savedData = [OLString.returningUser: false]
        // AND I have logged in
        let loginSession = await MockLoginSession(window: UIWindow())
        try await sut.startSession(
            loginSession,
            using: MockLoginSessionConfiguration.oneLoginSessionConfiguration
        )
        // WHEN I attempt to save my session
        try sut.saveSession()
        // THEN my session data is updated in the store
        XCTAssertEqual(mockEncryptedSecureStoreManager.savedItems, [OLString.refreshTokenExpiry: "1719397758.0",
                                                                    OLString.persistentSessionID: "1d003342-efd1-4ded-9c11-32e0f15acae6"])
        XCTAssertEqual(mockUnprotectedStore.savedData.count, 2)
    }
    
    func test_saveSession_doesNotRefreshSecureStoreManager() async throws {
        // GIVEN I am a new user
        mockUnprotectedStore.savedData = [OLString.returningUser: false]
        try mockAccessControlEncryptedSecureStoreManager.saveItem(
            item: "storedTokens",
            itemName: OLString.storedTokens
        )
        // AND I have logged in
        let loginSession = await MockLoginSession(window: UIWindow())
        try await sut.startSession(
            loginSession,
            using: MockLoginSessionConfiguration.oneLoginSessionConfiguration
        )
        // WHEN I attempt to save my session
        try sut.saveSession()
        // THEN the secure store manager is not refreshed
        XCTAssertFalse(mockAccessControlEncryptedSecureStoreManager.didCallClearSessionData)
        XCTAssertFalse(mockEncryptedSecureStoreManager.didCallClearSessionData)
        // THEN the session data is updated in the store
        XCTAssertEqual(mockEncryptedSecureStoreManager.savedItems, [OLString.refreshTokenExpiry: "1719397758.0",
                                                                    OLString.persistentSessionID: "1d003342-efd1-4ded-9c11-32e0f15acae6"])
        XCTAssertEqual(mockUnprotectedStore.savedData.count, 2)
    }
    
    func test_resumeSession_restoresUserAndAccessToken() throws {
        let data = encodeKeys(
            idToken: MockJWTs.genericToken,
            refreshToken: MockJWTs.genericToken,
            accessToken: MockJWTs.genericToken
        )
        // GIVEN I have tokens saved in secure store
        try mockAccessControlEncryptedSecureStoreManager.saveItem(
            item: data,
            itemName: OLString.storedTokens
        )
        // AND I am a returning user with local auth enabled
        let date = Date.distantFuture
        mockUnprotectedStore.savedData = [OLString.returningUser: true, OLString.accessTokenExpiry: date]
        mockLocalAuthentication.localAuthIsEnabledOnTheDevice = true
        // WHEN I return to the app and authenticate successfully
        try sut.resumeSession()
        // THEN my session data is re-populated
        XCTAssertEqual(sut.user.value?.persistentID, "1d003342-efd1-4ded-9c11-32e0f15acae6")
        XCTAssertEqual(sut.user.value?.email, "mock@email.com")
        
        XCTAssertEqual(sut.tokenProvider.subjectToken, MockJWTs.genericToken)
    }
    
    func test_endCurrentSession_clearsDataFromSession() throws {
        let data = encodeKeys(
            idToken: MockJWTs.genericToken,
            refreshToken: MockJWTs.genericToken,
            accessToken: MockJWTs.genericToken
        )
        // GIVEN I have tokens saved in secure store
        try mockAccessControlEncryptedSecureStoreManager.saveItem(
            item: data,
            itemName: OLString.storedTokens
        )
        // AND I am a returning user with local auth enabled
        let date = Date.distantFuture
        mockUnprotectedStore.savedData = [OLString.returningUser: true, OLString.accessTokenExpiry: date]
        mockLocalAuthentication.localAuthIsEnabledOnTheDevice = true
        
        try sut.resumeSession()
        // WHEN I end the session
        sut.endCurrentSession()
        // THEN my data is cleared
        XCTAssertNil(sut.tokenProvider.subjectToken)
        XCTAssertNil(sut.user.value)
        
        XCTAssertEqual(mockAccessControlEncryptedSecureStoreManager.savedItems, [:])
    }
    
    func test_endCurrentSession_clearsAllPersistedData() async throws {
        // GIVEN I have an expired session
        mockUnprotectedStore.savedData = [
            OLString.returningUser: true,
            OLString.accessTokenExpiry: Date.distantPast
        ]
        mockEncryptedSecureStoreManager.savedItems = [
            OLString.persistentSessionID: UUID().uuidString
        ]
        sut.registerSessionBoundData([
            mockUnprotectedStore,
            mockAccessControlEncryptedSecureStoreManager,
            mockEncryptedSecureStoreManager
        ])
        // WHEN I clear all session data
        try await sut.clearAllSessionData(restartLoginFlow: true)
        // THEN my session data is deleted
        XCTAssertEqual(mockUnprotectedStore.savedData.count, 0)
        XCTAssertEqual(mockEncryptedSecureStoreManager.savedItems, [:])
    }
    
    func test_hasNotRemovedLocalAuth_throwsError_whenPasscodeRemoved() throws {
        // GIVEN I am a returning user with an active session
        let date = Date.distantFuture
        mockUnprotectedStore.savedData = [OLString.returningUser: true, OLString.accessTokenExpiry: date]
        // WHEN remove my passcode
        mockLocalAuthentication.localAuthIsEnabledOnTheDevice = false
        // AND I try to resume a session
        XCTAssertThrowsError(try sut.resumeSession()) { error in
            // THEN an error is thrown
            guard case PersistentSessionError.userRemovedLocalAuth = error else {
                XCTFail("Expected local auth removed error")
                return
            }
        }
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
            keysAsData = try JSONEncoder().encode(mockStoredTokens).base64EncodedString()
        } catch {
            print("error")
        }
        return keysAsData
    }
}

extension PersistentSessionManagerTests: SessionBoundData {
    func clearSessionData() {
        didCall_deleteSessionBoundData = true
    }
}
