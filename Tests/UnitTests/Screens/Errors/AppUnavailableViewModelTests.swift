import GDSAnalytics
@testable import OneLogin
import XCTest

@MainActor
final class AppUnavailableViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: AppUnavailableViewModel!

    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        sut = AppUnavailableViewModel(analyticsService: mockAnalyticsService)
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        sut = nil

        super.tearDown()
    }
}

extension AppUnavailableViewModelTests {
    func test_page() {
        XCTAssertEqual(sut.imageWeight, .regular)
        XCTAssertEqual(sut.image, "exclamationmark.circle")
        XCTAssertEqual(sut.title.stringKey, "app_appUnavailableTitle")
        XCTAssertEqual(sut.body?.stringKey, "app_appUnavailableBody")
        XCTAssertNil(sut.rightBarButtonTitle)
        XCTAssertTrue(sut.backButtonIsHidden)
    }

    func test_didAppear() {
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.appUnavailable.rawValue,
                                     screen: ErrorAnalyticsScreen.appUnavailable,
                                     titleKey: "app_appUnavailableTitle")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged, screen.parameters)
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level2"] as? String, AppTaxonomy.system.rawValue)
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level3"] as? String, "undefined")
    }
}
