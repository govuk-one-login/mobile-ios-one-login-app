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
}
