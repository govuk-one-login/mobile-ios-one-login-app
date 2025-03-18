import GDSAnalytics
@testable import OneLogin
import XCTest

@MainActor
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
    func test_page() {
        XCTAssertEqual(sut.image, UIImage(named: "badge"))
        XCTAssertEqual(sut.title.stringKey, "app_signInTitle")
        XCTAssertEqual(sut.body.stringKey, "app_signInBody")
        
    }
    
    func test_button() {
        XCTAssertEqual(sut.introButtonViewModel.title.stringKey, "app_extendedSignInButton")
        XCTAssertFalse(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        sut.introButtonViewModel.action()
        XCTAssertTrue(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        let event = LinkEvent(textKey: "app_extendedSignInButton",
                              linkDomain: AppEnvironment.mobileBaseURLString,
                              external: .false)
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, event.parameters)
    }
    
    func test_didAppear() {
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(id: IntroAnalyticsScreenID.welcome.rawValue,
                                screen: IntroAnalyticsScreen.welcome,
                                titleKey: "app_signInTitle")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged, screen.parameters)
    }
}
