@testable import OneLogin
import XCTest

final class PersistentSessionManagerTests: XCTestCase {
    private var sut: PersistentSessionManager!

    private var accessControlEncryptedStore: MockSecureStoreService!
    private var encryptedStore: MockSecureStoreService!
    private var unprotectedStore: MockDefaultsStore!

    override func setUp() {
        super.setUp()

        accessControlEncryptedStore = MockSecureStoreService()
        encryptedStore = MockSecureStoreService()

        unprotectedStore = MockDefaultsStore()

        sut = PersistentSessionManager(
            accessControlEncryptedStore: accessControlEncryptedStore,
            encryptedStore: encryptedStore,
            unprotectedStore: unprotectedStore
        )
    }

    override func tearDown() {
        super.tearDown()

        sut = nil

        unprotectedStore = nil

        accessControlEncryptedStore = nil
        encryptedStore = nil
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
        let date = Date()
        unprotectedStore.set(date, forKey: .accessTokenExpiry)
        // THEN the session is not valid
        XCTAssertFalse(sut.isSessionValid)
    }

    func testIsReturningUserPullsFromStore() {
        unprotectedStore.set(true, forKey: .returningUser)
        XCTAssertTrue(sut.isReturningUser)
    }

    func testStartSession_logsTheUserIn() async throws {
        // GIVEN I am not logged in
        let loginSession = MockLoginSession()
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

        let loginSession = MockLoginSession()
        // WHEN I start a session
        try await sut.startSession(using: loginSession)
        // THEN a login screen is shown
        XCTAssertTrue(loginSession.didCallPerformLoginFlow)
        // AND a persistent session ID is provided
        let configuration = try XCTUnwrap(loginSession.sessionConfiguration)
        XCTAssertEqual(configuration.persistentSessionId, persistentSessionID)
    }

    func testResumeSession_restoresUserAndAccessToken() throws {
        // GIVEN my session has not expired
        unprotectedStore.set(Date.distantPast,
                             forKey: .accessTokenExpiry)
        try accessControlEncryptedStore.saveItem(item: MockJWKSResponse.idToken,
                                    itemName: .idToken)
        try accessControlEncryptedStore.saveItem(item: MockJWKSResponse.idToken,
                                    itemName: .accessToken)
        // WHEN I return to the app
        try sut.resumeSession()

        // THEN my session data is re-populated
        XCTAssertEqual(sut.user?.persistentID, "1d003342-efd1-4ded-9c11-32e0f15acae6")
        XCTAssertEqual(sut.user?.email, "mock@email.com")

        XCTAssertEqual(sut.tokenProvider.accessToken, MockJWKSResponse.idToken)
    }

    func testEndCurrentSession_clearsDataFromSession() throws {
        // GIVEN my session is valid
        unprotectedStore.set(Date.distantPast,
                             forKey: .accessTokenExpiry)
        try accessControlEncryptedStore.saveItem(item: MockJWKSResponse.idToken,
                                    itemName: .idToken)
        try accessControlEncryptedStore.saveItem(item: MockJWKSResponse.idToken,
                                    itemName: .accessToken)
        try sut.resumeSession()
        // WHEN I end the session
        sut.endCurrentSession()
        // THEN my data is cleared
        XCTAssertNil(sut.tokenProvider.accessToken)
        XCTAssertNil(sut.user)

        XCTAssertEqual(accessControlEncryptedStore.savedItems, [:])
    }

    func testEndCurrentSession_clearsAllPersistedData() {
        // GIVEN I have an expired session
        unprotectedStore.savedData = [
            .returningUser: UUID(),
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
