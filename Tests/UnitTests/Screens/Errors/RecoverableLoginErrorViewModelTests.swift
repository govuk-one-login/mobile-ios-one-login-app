import GDSAnalytics
@testable import OneLogin
import XCTest

@MainActor
final class RecoverableLoginErrorViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: RecoverableLoginErrorViewModel!
    
    var didCallButtonAction = false
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        sut = RecoverableLoginErrorViewModel(analyticsService: mockAnalyticsService,
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

extension RecoverableLoginErrorViewModelTests {
    func test_page() {
        XCTAssertEqual(sut.image, .error)
        XCTAssertEqual(sut.title.stringKey, "app_signInErrorTitle")
        XCTAssertEqual(sut.bodyContent.count, 1)
    }
    
    func test_button() {
        XCTAssertEqual(sut.buttonViewModels[0].title.stringKey, "app_tryAgainButton")
        XCTAssertFalse(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        sut.buttonViewModels[0].action()
        XCTAssertTrue(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        let event = ButtonEvent(textKey: "app_tryAgainButton")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, event.parameters)
    }
    
    func test_didAppear() {
        XCTAssertEqual(mockAnalyticsService.screenViews.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screenViews.count, 1)
        let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.recoverableLoginError.rawValue,
                                     screen: ErrorAnalyticsScreen.recoverablLoginError,
                                     titleKey: "app_signInErrorTitle",
                                     reason: "error description")
        XCTAssertEqual(mockAnalyticsService.screenViews as? [ErrorScreenView], [screen])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged, screen.parameters)
    }
}
