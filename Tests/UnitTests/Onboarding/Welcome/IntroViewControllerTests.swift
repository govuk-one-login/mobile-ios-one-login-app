import Authentication
import GDSAnalytics
import GDSCommon
@testable import OneLogin
import XCTest

final class IntroViewControllerTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var mockLoginSession: MockLoginSession!
    var mockLoginConfiguration: LoginSessionConfiguration!
    var mockViewModel: MockOneLoginIntroViewModel!
    var sut: IntroViewController!
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        mockLoginSession = MockLoginSession(window: UIWindow())
        mockLoginConfiguration = LoginSessionConfiguration(authorizationEndpoint: URL(string: "https://www.google.com")!,
                                                           tokenEndpoint: URL(string: "https://www.google.com/token")!,
                                                           clientID: "1234",
                                                           redirectURI: "https://www.google.com/redirect")
        mockViewModel = MockOneLoginIntroViewModel(analyticsService: mockAnalyticsService) {
            self.mockLoginSession.present(configuration: self.mockLoginConfiguration)
        }
        sut = IntroViewController(viewModel: mockViewModel)
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        mockLoginSession = nil
        mockLoginConfiguration = nil
        mockViewModel = nil
        sut = nil
        
        super.tearDown()
    }
}

extension IntroViewControllerTests {
    func test_sessionPresent() throws {
        XCTAssertFalse(mockLoginSession.didCallPresent)
        let introButton: UIButton = try XCTUnwrap(sut.view[child: "intro-button"])
        introButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(mockLoginSession.didCallPresent)
        XCTAssertTrue(mockLoginSession.sessionConfiguration != nil)
    }
    
    func test_triggerButtonAnalytics() throws {
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        let introButton: UIButton = try XCTUnwrap(sut.view[child: "intro-button"])
        introButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        let event = ButtonEvent(textKey: "testbutton")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["text"], event.text)
    }
    
    func test_triggerScreenAnalytics() throws {
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(screen: IntroAnalyticsScreen.welcomeScreen,
                                titleKey: "testtitle")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged["title"], screen.title)
    }
}
