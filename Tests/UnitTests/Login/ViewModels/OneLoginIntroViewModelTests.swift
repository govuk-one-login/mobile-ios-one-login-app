import GDSAnalytics
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
    func test_label_contents() throws {
        XCTAssertEqual(sut.image, UIImage(named: "badge"))
        XCTAssertEqual(sut.title.stringKey, "app_signInTitle")
        XCTAssertEqual(sut.body.stringKey, "app_signInBody")
        XCTAssertTrue(sut.introButtonViewModel is AnalyticsButtonViewModel)
    }
    
    func test_button_action() throws {
        XCTAssertFalse(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        sut.introButtonViewModel.action()
        XCTAssertTrue(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        let event = LinkEvent(textKey: "app_signInButton",
                              linkDomain: AppEnvironment.oneLoginBaseURL,
                              external: .false)
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["text"], event.parameters["text"])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["type"], event.parameters["type"])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["link_domain"], event.parameters["link_domain"])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["external"], event.parameters["external"])
    }
    
    func test_didAppear() throws {
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(id: IntroAnalyticsScreenID.welcomeScreen.rawValue,
                                screen: IntroAnalyticsScreen.welcomeScreen,
                                titleKey: "app_signInTitle")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged["title"], screen.parameters["title"])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged["screen_id"], screen.parameters["screen_id"])
    }
}
