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
        unprotectedStore.set(persistentSessionID, forKey: .persistentSessionID)

        let loginSession = MockLoginSession()
        // WHEN I start a session
        do {
            try await sut.startSession(using: loginSession)
        } catch {

        }
        // THEN a login screen is shown
        XCTAssertTrue(loginSession.didCallPerformLoginFlow)
        // AND a persistent session ID is provided
        let configuration = try XCTUnwrap(loginSession.sessionConfiguration)
        XCTAssertEqual(configuration.persistentSessionId, persistentSessionID)
    }
}
