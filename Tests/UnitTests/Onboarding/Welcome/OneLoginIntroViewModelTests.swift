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
    func test_labelContents() throws {
        XCTAssertEqual(sut.image, UIImage(named: "badge"))
        XCTAssertEqual(sut.title.value, "GOV.UK One Login")
        XCTAssertEqual(sut.body.value, "Sign in with the email address you use for your GOV.UK One Login.")
        XCTAssertTrue(sut.introButtonViewModel is AnalyticsButtonViewModel)
    }
    
    func test_buttonAction() throws {
        XCTAssertFalse(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        sut.introButtonViewModel.action()
        XCTAssertTrue(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        let event = ButtonEvent(textKey: sut.introButtonViewModel.title.value)
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["text"], event.text.lowercased())
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["type"], event.type.rawValue)
    }
    
    func test_didAppear() throws {
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(screen: IntroAnalyticsScreen.welcomeScreen,
                                titleKey: "gov.uk one login")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged["title"], screen.title)
    }
}
