@testable import OneLogin
import XCTest

@MainActor
final class DeveloperMenuViewModelTests: XCTestCase {
    var sut: DeveloperMenuViewModel!
    
    override func setUp() {
        super.setUp()

        sut = DeveloperMenuViewModel()
    }

    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
}

extension DeveloperMenuViewModelTests {
    func test_screen_contents() throws {
        XCTAssertEqual(sut.rightBarButtonTitle?.stringKey, "app_cancelButton")
    }
}
