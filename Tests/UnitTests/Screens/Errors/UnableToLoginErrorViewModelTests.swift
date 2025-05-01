import GDSAnalytics
@testable import OneLogin
import XCTest

@MainActor
final class UnableToLoginErrorViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: UnableToLoginErrorViewModel!
    
    var didCallButtonAction = false
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        sut = UnableToLoginErrorViewModel(analyticsService: mockAnalyticsService,
                                          errorDescription: "error description") {
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

extension UnableToLoginErrorViewModelTests {
    func test_page() {
        XCTAssertEqual(sut.image, .error)
        XCTAssertEqual(sut.title.stringKey, "app_signInErrorTitle")
        XCTAssertEqual(sut.bodyContent.count, 1)
    }
    
    func test_button() {
        XCTAssertEqual(sut.buttonViewModels[0].title.stringKey, "app_closeButton")
        XCTAssertFalse(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        sut.buttonViewModels[0].action()
        XCTAssertTrue(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        let event = ButtonEvent(textKey: "app_closeButton")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, event.parameters)
    }
    
    func test_didAppear() {
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.unableToLogin.rawValue,
                                     screen: ErrorAnalyticsScreen.unableToLogin,
                                     titleKey: "app_signInErrorTitle",
                                     reason: "error description")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged, screen.parameters)
    }
}
