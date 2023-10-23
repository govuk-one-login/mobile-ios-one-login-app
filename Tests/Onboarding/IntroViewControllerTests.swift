import GDSCommon
@testable import OneLogin
import XCTest

final class IntroViewControllerTests: XCTestCase {
    var loginSession: MockLoginSession!
    var mockAnalyticsService: MockAnalyticsService!
    var sut: IntroViewController!
    
    override func setUp() {
        super.setUp()

        loginSession = MockLoginSession(window: UIWindow())
        mockAnalyticsService = MockAnalyticsService()
        sut = ViewControllerFactory(analyticsService: mockAnalyticsService).createIntroViewController(session: loginSession)
    }
    
    override func tearDown() {
        loginSession = nil
        sut = nil
        
        super.tearDown()
    }
}

extension IntroViewControllerTests {
    func test_sessionPresent() throws {
        XCTAssertFalse(loginSession.didCallPresent)
        let introButton: UIButton = try XCTUnwrap(sut.view[child: "intro-button"])
        introButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(loginSession.didCallPresent)
    }
}
