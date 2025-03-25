import GDSAnalytics
@testable import OneLogin
import XCTest

@MainActor
final class NetworkConnectionErrorViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: NetworkConnectionErrorViewModel!
    
    var didCallButtonAction = false
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        sut = NetworkConnectionErrorViewModel(analyticsService: mockAnalyticsService) {
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

extension NetworkConnectionErrorViewModelTests {
    func test_page() {
        XCTAssertEqual(sut.image, "exclamationmark.circle")
        XCTAssertEqual(sut.title.stringKey, "app_networkErrorTitle")
        XCTAssertEqual(sut.body.stringKey, "app_networkErrorBody")
        XCTAssertNil(sut.rightBarButtonTitle)
        XCTAssertTrue(sut.backButtonIsHidden)
    }
    
    func test_button() {
        XCTAssertEqual(sut.primaryButtonViewModel.title.stringKey, "app_tryAgainButton")
        XCTAssertFalse(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        sut.primaryButtonViewModel.action()
        XCTAssertTrue(didCallButtonAction)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        let event = ButtonEvent(textKey: "app_tryAgainButton")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, event.parameters)
    }
    
    func test_didAppear() {
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.networkConnection.rawValue,
                                     screen: ErrorAnalyticsScreen.networkConnection,
                                     titleKey: "app_networkErrorTitle",
                                     reason: "network connection error")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged, screen.parameters)
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level2"] as? String, OLTaxonomyValue.system)
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level3"] as? String, OLTaxonomyValue.error)
    }
}
