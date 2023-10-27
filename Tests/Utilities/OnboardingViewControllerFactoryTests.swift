import Authentication
@testable import OneLogin
import XCTest

final class OnboardingViewControllerFactoryTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var mockLoginSession: MockLoginSession!
    var sut: OnboardingViewControllerFactory.Type!
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        mockLoginSession = MockLoginSession(window: UIWindow())
        sut = OnboardingViewControllerFactory.self
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        mockLoginSession = nil
        sut = nil
        
        super.tearDown()
    }
}

extension OnboardingViewControllerFactoryTests {
    func test_createIntroViewController() throws {
        _ = sut.createIntroViewController(analyticsService: mockAnalyticsService, session: mockLoginSession)
        XCTAssertTrue(mockLoginSession.sessionConfiguration != nil)
    }
}
