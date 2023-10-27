@testable import OneLogin
import XCTest

final class OneLoginIntroViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: OneLoginIntroViewModel!
    var didCallButtonAction = false
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        sut = OneLoginIntroViewModel(analyticsService: mockAnalyticsService) {
            self.didCallButtonAction = true
        }
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        sut = nil
        didCallButtonAction = false
        
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
