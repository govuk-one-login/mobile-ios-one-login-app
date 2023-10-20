import Authentication
@testable import OneLogin
import XCTest

final class OneLoginIntroViewModelTests: XCTestCase {
    var sut: OneLoginIntroViewModel!
    var mockLoginSession: MockLoginSession!
    var didCallButtonAction = false
    
    override func setUp() {
        super.setUp()
        mockLoginSession = MockLoginSession()
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
    func test_labelContents() throws {
        XCTAssertEqual(sut.image, UIImage(named: "badge"))
        XCTAssertEqual(sut.title.value, "GOV.UK One Login")
        XCTAssertEqual(sut.body.value, "Sign in with the email address you use for your GOV.UK One Login.")
        XCTAssertTrue(sut.introButtonViewModel is AnalyticsButtonViewModel)
    }
    
    func test_buttonAction() async throws {
        XCTAssertFalse(didCallButtonAction)
        sut.introButtonViewModel.action()
        XCTAssertTrue(didCallButtonAction)
    }
}
