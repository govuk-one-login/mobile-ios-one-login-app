import Authentication
import MobilePlatformServices
import Networking
@testable @preconcurrency import OneLogin
import XCTest

final class PersistentSessionManagerTests: XCTestCase {
    private var mockAccessControlEncryptedStore: MockSecureStoreService!
    private var mockEncryptedStore: MockSecureStoreService!
    private var mockLocalAuthentication: MockLocalAuthManager!
    private var mockSecureStoreManager: MockSecureStoreManager!
    private var mockUnprotectedStore: MockDefaultsStore!
    private var mockStoredTokens: StoredTokens!
    private var sut: PersistentSessionManager!
    private var didCall_deleteSessionBoundData = false
    
    @MainActor
    override func setUp() {
        super.setUp()
        
        mockAccessControlEncryptedStore = MockSecureStoreService()
        mockEncryptedStore = MockSecureStoreService()
        mockLocalAuthentication = MockLocalAuthManager()
        mockSecureStoreManager = MockSecureStoreManager(
            accessControlEncryptedStore: mockAccessControlEncryptedStore,
            encryptedStore: mockEncryptedStore,
            localAuthentication: mockLocalAuthentication
        )
        mockUnprotectedStore = MockDefaultsStore()
        
        sut = PersistentSessionManager(
            secureStoreManager: mockSecureStoreManager,
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
        mockLocalAuthentication = nil
        mockSecureStoreManager = nil
        mockUnprotectedStore = nil
        mockStoredTokens = nil
        
        sut = nil
        didCall_deleteSessionBoundData = false
        
        super.tearDown()
    }
}

extension PersistentSessionManagerTests {
    func testInitialState() {
        XCTAssertNil(sut.expiryDate)
        XCTAssertFalse(sut.sessionExists)
        XCTAssertFalse(sut.isSessionValid)
        XCTAssertFalse(sut.isReturningUser)
    }
    
    func testSessionExpiryDate() {
        // GIVEN the unprotected store contains a session expiry date
        let date = Date()
        mockUnprotectedStore.set(date, forKey: .accessTokenExpiry)
        // THEN it is exposed by the session manager
        XCTAssertEqual(sut.expiryDate, date)
    }
    
    func testSessionIsValidWhenNotExpired() {
        // GIVEN the unprotected store contains a session expiry date in the future
        let date = Date.distantFuture
        mockUnprotectedStore.set(date, forKey: .accessTokenExpiry)
        // THEN the session is not valid
        XCTAssertTrue(sut.isSessionValid)
    }
    
    func testSessionIsInvalidWhenExpired() {
        // GIVEN the unprotected store contains a session expiry date in the past
        let date = Date.distantPast
        mockUnprotectedStore.set(date, forKey: .accessTokenExpiry)
        // THEN the session is not valid
        XCTAssertFalse(sut.isSessionValid)
    }
    
    func testIsReturningUserPullsFromStore() {
        mockUnprotectedStore.set(true, forKey: .returningUser)
        XCTAssertTrue(sut.isReturningUser)
    }
    
    func test_hasNotRemovedLocalAuth() throws {
        mockLocalAuthentication.LAlocalAuthIsEnabledOnTheDevice = true
        mockUnprotectedStore.set(true, forKey: .returningUser)
        XCTAssertTrue(hasNotRemovedLocalAuth)
    }
    
    func test_hasRemovedLocalAuth() throws {
        mockLocalAuthentication.LAlocalAuthIsEnabledOnTheDevice = false
        mockUnprotectedStore.set(true, forKey: .returningUser)
        XCTAssertFalse(hasNotRemovedLocalAuth)
    }
    
    func test_hasRemovedLocalAuth_inverse() throws {
        mockLocalAuthentication.LAlocalAuthIsEnabledOnTheDevice = true
        mockUnprotectedStore.set(false, forKey: .returningUser)
        XCTAssertFalse(hasNotRemovedLocalAuth)
    }
    
    @MainActor
    func testStartSession_logsTheUserIn() async throws {
        // GIVEN I am not logged in
        let loginSession = MockLoginSession(window: UIWindow())
        // WHEN I start a session
        try await sut.startSession(loginSession, using: LoginSessionConfiguration.oneLoginSessionConfiguration)
        // THEN a login screen is shown
        XCTAssertTrue(loginSession.didCallPerformLoginFlow)
        // AND no persistent session ID is provided
        let configuration = try XCTUnwrap(loginSession.sessionConfiguration)
        XCTAssertNil(configuration.persistentSessionId)
    }
    
    @MainActor
    func testStartSession_logsTheUserIn_appIntegrity() async throws {
        AppEnvironment.updateFlags(
            releaseFlags: [:],
            featureFlags: [FeatureFlagsName.appCheckEnabled.rawValue: true]
        )
        // GIVEN I am not logged in
        let loginSession = MockLoginSession(window: UIWindow())
        // WHEN I start a session
        try await sut.startSession(loginSession, using: MockLoginSessionConfiguration.oneLoginSessionConfiguration)
        // THEN a login screen is shown
        XCTAssertTrue(loginSession.didCallPerformLoginFlow)
        // AND no persistent session ID is provided
        let configuration = try XCTUnwrap(loginSession.sessionConfiguration)
        XCTAssertEqual(configuration.persistentSessionId, "123456789")
    }
    
    @MainActor
    func test_startSession_reauthenticatesTheUser() async throws {
        // GIVEN my session has expired
        let persistentSessionID = UUID().uuidString
        try mockEncryptedStore.saveItem(item: persistentSessionID,
                                        itemName: .persistentSessionID)
        
        let loginSession = MockLoginSession(window: UIWindow())
        // WHEN I start a session
        try await sut.startSession(loginSession, using: LoginSessionConfiguration.oneLoginSessionConfiguration)
        // THEN a login screen is shown
        XCTAssertTrue(loginSession.didCallPerformLoginFlow)
        // AND a persistent session ID is provided
        let configuration = try XCTUnwrap(loginSession.sessionConfiguration)
        XCTAssertEqual(configuration.persistentSessionId, persistentSessionID)
    }
    
    func test_startSession_cannotReauthenticateWithoutPersistentSessionID() async throws {
        let exp = XCTNSNotificationExpectation(
            name: .didLogout,
            object: nil,
            notificationCenter: NotificationCenter.default
        )
        
        // GIVEN I am a returning user
        mockUnprotectedStore.set(true, forKey: .returningUser)
        sut.registerSessionBoundData([self])
        // AND I am unable to re-authenticate because I have no persistent session ID
        mockEncryptedStore.deleteItem(itemName: .persistentSessionID)
        // WHEN I start a session
        do {
            let loginSession = await MockLoginSession(window: UIWindow())
            try await sut.startSession(loginSession, using: LoginSessionConfiguration.oneLoginSessionConfiguration)
            
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
    
    func testStartSession_exposesUserAndAccessToken() async throws {
        // GIVEN I am logged in
        let loginSession = await MockLoginSession(window: UIWindow())
        // WHEN I start a session
        try await sut.startSession(loginSession, using: LoginSessionConfiguration.oneLoginSessionConfiguration)
        // THEN my User details
        XCTAssertEqual(sut.user.value?.persistentID, "1d003342-efd1-4ded-9c11-32e0f15acae6")
        XCTAssertEqual(sut.user.value?.email, "mock@email.com")
        // AND access token are populated
        XCTAssertEqual(sut.tokenProvider.subjectToken, "accessTokenResponse")
    }
    
    func testStartSession_skipsSavingTokensForNewUsers() async throws {
        // GIVEN I am not logged in
        let loginSession = await MockLoginSession(window: UIWindow())
        // WHEN I start a session
        try await sut.startSession(loginSession, using: LoginSessionConfiguration.oneLoginSessionConfiguration)
        // THEN my session data is not saved
        XCTAssertEqual(mockEncryptedStore.savedItems, [:])
        XCTAssertEqual(mockUnprotectedStore.savedData.count, 0)
    }
    
    func testStartSession_savesTokensForReturningUsers() async throws {
        let exp = XCTNSNotificationExpectation(
            name: .enrolmentComplete,
            object: nil,
            notificationCenter: NotificationCenter.default
        )
        
        // GIVEN I am a returning user
        mockUnprotectedStore.savedData = [.returningUser: true]
        let persistentSessionID = UUID().uuidString
        try mockEncryptedStore.saveItem(item: persistentSessionID,
                                        itemName: .persistentSessionID)
        // WHEN I re-authenticate
        let loginSession = await MockLoginSession(window: UIWindow())
        try await sut.startSession(loginSession, using: LoginSessionConfiguration.oneLoginSessionConfiguration)
        // THEN my session data is updated in the store
        XCTAssertEqual(mockEncryptedStore.savedItems, [.persistentSessionID: "1d003342-efd1-4ded-9c11-32e0f15acae6"])
        XCTAssertEqual(mockUnprotectedStore.savedData.count, 2)
        // AND the user can be returned to where they left off
        await fulfillment(of: [exp], timeout: 5)
    }
    
    func test_saveSession_enrolsLocalAuthenticationForNewUsers() async throws {
        // GIVEN I am a new user
        mockUnprotectedStore.savedData = [.returningUser: false]
        // AND I have logged in
        let loginSession = await MockLoginSession(window: UIWindow())
        try await sut.startSession(loginSession, using: LoginSessionConfiguration.oneLoginSessionConfiguration)
        // WHEN I attempt to save my session
        try await sut.saveSession()
        // THEN the user is asked to consent to biometrics if available
        XCTAssertTrue(mockLocalAuthentication.didCallEnrolFaceIDIfAvailable)
        // THEN my session data is updated in the store
        XCTAssertEqual(mockEncryptedStore.savedItems, [.persistentSessionID: "1d003342-efd1-4ded-9c11-32e0f15acae6"])
        XCTAssertEqual(mockUnprotectedStore.savedData.count, 2)
    }
    
    func test_saveSession_doesNotSaveDataWhenDeclinesPermissionForFaceID() async throws {
        // GIVEN I am a new user
        mockUnprotectedStore.savedData = [.returningUser: false]
        // AND I decline consent for Face ID
        mockLocalAuthentication.userDidConsentToFaceID = false
        // AND I have logged in
        let loginSession = await MockLoginSession(window: UIWindow())
        try await sut.startSession(loginSession, using: LoginSessionConfiguration.oneLoginSessionConfiguration)
        // WHEN I attempt to save my session
        try await sut.saveSession()
        // THEN my session data is not stored
        XCTAssertEqual(mockEncryptedStore.savedItems, [:])
        XCTAssertEqual(mockUnprotectedStore.savedData.count, 1)
    }
    
    func testResumeSession_restoresUserAndAccessToken() throws {
        let data = encodeKeys(idToken: MockJWKSResponse.idToken,
                              accessToken: MockJWKSResponse.idToken)
        // GIVEN I have tokens saved in secure store
        try mockAccessControlEncryptedStore.saveItem(item: data,
                                                 itemName: .storedTokens)
        // AND I am a returning user with local auth enabled
        let date = Date.distantFuture
        mockUnprotectedStore.savedData = [.returningUser: true, .accessTokenExpiry: date]
        mockLocalAuthentication.LAlocalAuthIsEnabledOnTheDevice = true
        // WHEN I return to the app and authenticate successfully
        try sut.resumeSession()
        // THEN my session data is re-populated
        XCTAssertEqual(sut.user.value?.persistentID, "1d003342-efd1-4ded-9c11-32e0f15acae6")
        XCTAssertEqual(sut.user.value?.email, "mock@email.com")
        
        XCTAssertEqual(sut.tokenProvider.subjectToken, MockJWKSResponse.idToken)
    }
    
    func testEndCurrentSession_clearsDataFromSession() throws {
        let data = encodeKeys(idToken: MockJWKSResponse.idToken,
                              accessToken: MockJWKSResponse.idToken)
        // GIVEN I have tokens saved in secure store
        try mockAccessControlEncryptedStore.saveItem(item: data,
                                                 itemName: .storedTokens)
        // AND I am a returning user with local auth enabled
        let date = Date.distantFuture
        mockUnprotectedStore.savedData = [.returningUser: true, .accessTokenExpiry: date]
        mockLocalAuthentication.LAlocalAuthIsEnabledOnTheDevice = true
        
        try sut.resumeSession()
        // WHEN I end the session
        sut.endCurrentSession()
        // THEN my data is cleared
        XCTAssertNil(sut.tokenProvider.subjectToken)
        XCTAssertNil(sut.user.value)
        
        XCTAssertEqual(mockAccessControlEncryptedStore.savedItems, [:])
    }
    
    func testEndCurrentSession_clearsAllPersistedData() throws {
        // GIVEN I have an expired session
        mockUnprotectedStore.savedData = [
            .returningUser: true,
            .accessTokenExpiry: Date.distantPast
        ]
        mockEncryptedStore.savedItems = [
            .persistentSessionID: UUID().uuidString
        ]
        // WHEN I clear all session data
        try sut.clearAllSessionData()
        // THEN my session data is deleted
        XCTAssertEqual(mockUnprotectedStore.savedData.count, 0)
        XCTAssertEqual(mockEncryptedStore.savedItems, [:])
    }
    
    func test_isSessionValid_throwsError() throws {
        // GIVEN I have an expired session
        mockUnprotectedStore.savedData = [
            .returningUser: true,
            .accessTokenExpiry: Date.distantPast
        ]
        mockEncryptedStore.savedItems = [
            .persistentSessionID: UUID().uuidString
        ]
        
        // WHEN I try to resume a session
        XCTAssertThrowsError(try sut.resumeSession()) { error in
            // THEN an error is thrown
            XCTAssertEqual(error as? TokenError, .expired)
        }
    }
    
    func test_hasNotRemovedLocalAuth_throwsError_whenPasscodeRemoved() throws {
        // GIVEN I am a returning user with an active session
        let date = Date.distantFuture
        mockUnprotectedStore.savedData = [.returningUser: true, .accessTokenExpiry: date]
        // WHEN remove my passcode
        mockLocalAuthentication.LAlocalAuthIsEnabledOnTheDevice = false
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
        mockLocalAuthentication.canUseLocalAuth(type: .deviceOwnerAuthentication) && sut.isReturningUser
    }
}

extension PersistentSessionManagerTests {
    private func encodeKeys(idToken: String, accessToken: String) -> String {
        mockStoredTokens = StoredTokens(idToken: idToken, accessToken: accessToken)
        var keysAsData: String = ""
        do {
            keysAsData = try JSONEncoder().encode(mockStoredTokens).base64EncodedString()
        } catch {
            print("error")
        }
        return keysAsData
    }
}

extension PersistentSessionManagerTests: SessionBoundData {
    func delete() throws {
        didCall_deleteSessionBoundData = true
    }
}
