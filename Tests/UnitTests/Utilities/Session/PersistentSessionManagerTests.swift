import Networking
@testable import OneLogin
import XCTest

final class PersistentSessionManagerTests: XCTestCase {
    private var sut: PersistentSessionManager!
    private var accessControlEncryptedStore: MockSecureStoreService!
    private var encryptedStore: MockSecureStoreService!
    private var unprotectedStore: MockDefaultsStore!
    private var localAuthentication: MockLocalAuthManager!

    override func setUp() {
        super.setUp()
        
        accessControlEncryptedStore = MockSecureStoreService()
        encryptedStore = MockSecureStoreService()
        unprotectedStore = MockDefaultsStore()
        localAuthentication = MockLocalAuthManager()
        
        sut = PersistentSessionManager(
            accessControlEncryptedStore: accessControlEncryptedStore,
            encryptedStore: encryptedStore,
            unprotectedStore: unprotectedStore,
            localAuthentication: localAuthentication
        )
    }
    
    override func tearDown() {
        AppEnvironment.updateReleaseFlags([:])
        
        accessControlEncryptedStore = nil
        encryptedStore = nil
        unprotectedStore = nil
        localAuthentication = nil

        sut = nil
        
        super.tearDown()
    }
}

extension PersistentSessionManagerTests {
    func testInitialState() {
        XCTAssertNil(sut.expiryDate)
        XCTAssertFalse(sut.sessionExists)
        XCTAssertFalse(sut.isSessionValid)
        XCTAssertFalse(sut.isReturningUser)
        XCTAssertFalse(sut.isPersistentSessionIDMissing)
    }
    
    func testSessionExpiryDate() {
        // GIVEN the unprotected store contains a session expiry date
        let date = Date()
        unprotectedStore.set(date, forKey: .accessTokenExpiry)
        // THEN it is exposed by the session manager
        XCTAssertEqual(sut.expiryDate, date)
    }
    
    func testSessionIsValidWhenNotExpired() {
        // GIVEN the unprotected store contains a session expiry date in the future
        let date = Date.distantFuture
        unprotectedStore.set(date, forKey: .accessTokenExpiry)
        // THEN the session is not valid
        XCTAssertTrue(sut.isSessionValid)
    }
    
    func testSessionIsInvalidWhenExpired() {
        // GIVEN the unprotected store contains a session expiry date in the past
        let date = Date.distantPast
        unprotectedStore.set(date, forKey: .accessTokenExpiry)
        // THEN the session is not valid
        XCTAssertFalse(sut.isSessionValid)
    }
    
    func testIsReturningUserPullsFromStore() {
        unprotectedStore.set(true, forKey: .returningUser)
        XCTAssertTrue(sut.isReturningUser)
    }
    
    func test_hasNotRemovedLocalAuth() throws {
        localAuthentication.LAlocalAuthIsEnabledOnTheDevice = true
        unprotectedStore.set(true, forKey: .returningUser)
        XCTAssertTrue(hasNotRemovedLocalAuth)
    }
    
    func test_hasRemovedLocalAuth() throws {
        localAuthentication.LAlocalAuthIsEnabledOnTheDevice = false
        unprotectedStore.set(true, forKey: .returningUser)
        XCTAssertFalse(hasNotRemovedLocalAuth)
    }
    
    func test_hasRemovedLocalAuth_inverse() throws {
        localAuthentication.LAlocalAuthIsEnabledOnTheDevice = true
        unprotectedStore.set(false, forKey: .returningUser)
        XCTAssertFalse(hasNotRemovedLocalAuth)
    }
    
    func testStartSession_logsTheUserIn() async throws {
        // GIVEN I am not logged in
        let loginSession = await MockLoginSession(window: UIWindow())
        // WHEN I start a session
        try await sut.startSession(using: loginSession)
        // THEN a login screen is shown
        XCTAssertTrue(loginSession.didCallPerformLoginFlow)
        // AND no persistent session ID is provided
        let configuration = try XCTUnwrap(loginSession.sessionConfiguration)
        XCTAssertNil(configuration.persistentSessionId)
    }
    
    func testStartSession_reauthenticatesTheUser() async throws {
        // GIVEN my session has expired
        let persistentSessionID = UUID().uuidString
        try encryptedStore.saveItem(item: persistentSessionID,
                                    itemName: .persistentSessionID)
        
        let loginSession = await MockLoginSession(window: UIWindow())
        // WHEN I start a session
        try await sut.startSession(using: loginSession)
        // THEN a login screen is shown
        XCTAssertTrue(loginSession.didCallPerformLoginFlow)
        // AND a persistent session ID is provided
        let configuration = try XCTUnwrap(loginSession.sessionConfiguration)
        XCTAssertEqual(configuration.persistentSessionId, persistentSessionID)
    }
    
    func testStartSession_exposesUserAndAccessToken() async throws {
        // GIVEN I am logged in
        let loginSession = await MockLoginSession(window: UIWindow())
        // AND I am calling STS
        AppEnvironment.updateReleaseFlags([
            FeatureFlags.enableCallingSTS.rawValue: true
        ])
        // WHEN I start a session
        try await sut.startSession(using: loginSession)
        // THEN my User details
        XCTAssertEqual(sut.user?.persistentID, "1d003342-efd1-4ded-9c11-32e0f15acae6")
        XCTAssertEqual(sut.user?.email, "mock@email.com")
        // AND access token are populated
        XCTAssertEqual(sut.tokenProvider.subjectToken, "accessTokenResponse")
    }

    func testStartSession_skipsSavingTokensForNewUsers() async throws {
        // GIVEN I am not logged in
        let loginSession = await MockLoginSession(window: UIWindow())
        // WHEN I start a session
        try await sut.startSession(using: loginSession)
        // THEN my session data is not saved
        XCTAssertEqual(accessControlEncryptedStore.savedItems, [:])
        XCTAssertEqual(encryptedStore.savedItems, [:])
        XCTAssertEqual(unprotectedStore.savedData.count, 0)
    }

    func testStartSession_savesTokensForReturningUsers() async throws {
        // GIVEN I am a returning user
        unprotectedStore.savedData = [.returningUser: true]
        let persistentSessionID = UUID().uuidString
        try encryptedStore.saveItem(item: persistentSessionID,
                                    itemName: .persistentSessionID)
        // WHEN I re-authenticate
        let loginSession = await MockLoginSession(window: UIWindow())
        try await sut.startSession(using: loginSession)
        // THEN my session data is updated in the store
        XCTAssertEqual(accessControlEncryptedStore.savedItems,
                       [.idToken: try MockTokenResponse().getJSONData().idToken,
                        .accessToken: "accessTokenResponse"])
        XCTAssertEqual(encryptedStore.savedItems, [.persistentSessionID: "1d003342-efd1-4ded-9c11-32e0f15acae6"])
        XCTAssertEqual(unprotectedStore.savedData.count, 2)
    }

    func test_saveSession_enrolsLocalAuthenticationForNewUsers() async throws {
        // GIVEN I am a new user
        unprotectedStore.savedData = [.returningUser: false]
        // AND I have logged in
        let loginSession = await MockLoginSession(window: UIWindow())
        try await sut.startSession(using: loginSession)
        // WHEN I attempt to save my session
        try await sut.saveSession()
        // THEN the user is asked to consent to biometrics if available
        XCTAssertTrue(localAuthentication.didCallEnrolFaceIDIfAvailable)
        // THEN my session data is updated in the store
        XCTAssertEqual(accessControlEncryptedStore.savedItems,
                       [.idToken: try MockTokenResponse().getJSONData().idToken,
                        .accessToken: "accessTokenResponse"])
        XCTAssertEqual(encryptedStore.savedItems, [.persistentSessionID: "1d003342-efd1-4ded-9c11-32e0f15acae6"])
        XCTAssertEqual(unprotectedStore.savedData.count, 2)
   }

    func test_saveSession_doesNotSaveDataWhenDeclinesPermissionForFaceID() async throws {
        // GIVEN I am a new user
        unprotectedStore.savedData = [.returningUser: false]
        // AND I decline consent for Face ID
        localAuthentication.userDidConsentToFaceID = false
        // AND I have logged in
        let loginSession = await MockLoginSession(window: UIWindow())
        try await sut.startSession(using: loginSession)
        // WHEN I attempt to save my session
        try await sut.saveSession()
        // THEN my session data is not stored
        XCTAssertEqual(accessControlEncryptedStore.savedItems, [:])
        XCTAssertEqual(encryptedStore.savedItems, [:])
        XCTAssertEqual(unprotectedStore.savedData.count, 1)
   }

    func testResumeSession_restoresUserAndAccessToken() throws {
        // GIVEN I have tokens saved in secure store
        try accessControlEncryptedStore.saveItem(item: MockJWKSResponse.idToken,
                                                 itemName: .idToken)
        try accessControlEncryptedStore.saveItem(item: MockJWKSResponse.idToken,
                                                 itemName: .accessToken)
        // AND I am a returning user with local auth enabled
        let date = Date.distantFuture
        unprotectedStore.savedData = [.returningUser: true, .accessTokenExpiry: date]
        localAuthentication.LAlocalAuthIsEnabledOnTheDevice = true
        // WHEN I return to the app and authenticate successfully
        try sut.resumeSession()
        // THEN my session data is re-populated
        XCTAssertEqual(sut.user?.persistentID, "1d003342-efd1-4ded-9c11-32e0f15acae6")
        XCTAssertEqual(sut.user?.email, "mock@email.com")
        
        XCTAssertEqual(sut.tokenProvider.subjectToken, MockJWKSResponse.idToken)
    }
    
    func testEndCurrentSession_clearsDataFromSession() throws {
        // GIVEN I have tokens saved in secure store
        try accessControlEncryptedStore.saveItem(item: MockJWKSResponse.idToken,
                                                 itemName: .idToken)
        try accessControlEncryptedStore.saveItem(item: MockJWKSResponse.idToken,
                                                 itemName: .accessToken)
        // AND I am a returning user with local auth enabled
        let date = Date.distantFuture
        unprotectedStore.savedData = [.returningUser: true, .accessTokenExpiry: date]
        localAuthentication.LAlocalAuthIsEnabledOnTheDevice = true
        try sut.resumeSession()
        // WHEN I end the session
        sut.endCurrentSession()
        // THEN my data is cleared
        XCTAssertNil(sut.tokenProvider.subjectToken)
        XCTAssertNil(sut.user)
        
        XCTAssertEqual(accessControlEncryptedStore.savedItems, [:])
    }
    
    func testEndCurrentSession_clearsAllPersistedData() {
        // GIVEN I have an expired session
        unprotectedStore.savedData = [
            .returningUser: true,
            .accessTokenExpiry: Date.distantPast
        ]
        encryptedStore.savedItems = [
            .persistentSessionID: UUID().uuidString
        ]
        // WHEN I clear all session data
        sut.clearAllSessionData()
        // THEN my session data is deleted
        XCTAssertEqual(unprotectedStore.savedData.count, 0)
        XCTAssertEqual(encryptedStore.savedItems, [:])
    }
}

extension PersistentSessionManagerTests {
    var hasNotRemovedLocalAuth: Bool {
        localAuthentication.canUseLocalAuth(type: .deviceOwnerAuthentication) && sut.isReturningUser
    }
}
