import XCTest
@testable import OneLogin

final class OneLoginIntroViewModelTests: XCTestCase {

    var sut: OneLoginIntroViewModel!
    var didCallButtonAction = false
    
    override func setUp() {
        super.setUp()
        sut = OneLoginIntroViewModel {
            self.didCallButtonAction = true
        }
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
}

extension OneLoginIntroViewModelTests {
    func test_buttonAction() throws {
        sut.introButtonViewModel.action()
        XCTAssertTrue(didCallButtonAction)
    }
}
