import GDSCommon
@testable import OneLogin
import XCTest

final class OnboardingViewControllerFactoryTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var mockLoginSession: MockLoginSession!
    var sut: OnboardingViewControllerFactory.Type!
    var didCallAction = false
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        sut = OnboardingViewControllerFactory.self
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        sut = nil
        didCallAction = false
        
        super.tearDown()
    }
}

extension OnboardingViewControllerFactoryTests {
    func test_introViewControllerCallsAction() throws {
        let introView = sut.createIntroViewController(analyticsService: mockAnalyticsService) {
            self.didCallAction = true
        }
        let introButton: UIButton = try XCTUnwrap(introView.view[child: "intro-button"])
        introButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(didCallAction)
    }
    
    func test_noPasscodeCallsAction() throws {
        let introView = sut.createPasscodeInformationScreen(analyticsService: mockAnalyticsService) {
            self.didCallAction = true
        }
        let introButton: UIButton = try XCTUnwrap(introView.view[child: "information-primary-button"])
        introButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(didCallAction)
    }
}
