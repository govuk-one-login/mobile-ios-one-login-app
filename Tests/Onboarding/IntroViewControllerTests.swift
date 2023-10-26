import GDSAnalytics
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
    
    func test_triggerButtonAnalytics() throws {
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        let introButton: UIButton = try XCTUnwrap(sut.view[child: "intro-button"])
        introButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        let event = ButtonEvent(textKey: "sign in")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["text"], event.text)
    }
    
    func test_triggerScreenAnalytics() throws {
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(screen: IntroAnalyticsScreen.welcomeScreen,
                                titleKey: "gov.uk one login")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged["title"], screen.title)
    }
}
