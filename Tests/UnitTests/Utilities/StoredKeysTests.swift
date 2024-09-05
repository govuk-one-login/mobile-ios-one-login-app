import Foundation
@testable import OneLogin
import XCTest

final class StoredKeysTests: XCTestCase {
    var sut: StoredKeyService!

    override func setUp() {
        super.setUp()

        sut = StoredKeyService()
    }

    override func tearDown() {
        sut = nil

        super.tearDown()
    }
}

extension StoredKeysTests {
    func test_canFetchStoredKeys() throws {

    }

    func test_canSaveKeys() throws {
        
    }
}
