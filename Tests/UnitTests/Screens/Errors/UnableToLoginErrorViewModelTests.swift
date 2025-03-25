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
        XCTAssertEqual(sut.image, "exclamationmark.circle")
        XCTAssertEqual(sut.title.stringKey, "app_signInErrorTitle")
        XCTAssertEqual(sut.body.stringKey, "app_signInErrorBody")
    }
    
    func test_button() {
        XCTAssertEqual(sut.primaryButtonViewModel.title.stringKey, "app_closeButton")
        XCTAssertFalse(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        sut.primaryButtonViewModel.action()
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
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level2"] as? String, OLTaxonomyValue.login)
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level3"] as? String, OLTaxonomyValue.error)
    }
}
