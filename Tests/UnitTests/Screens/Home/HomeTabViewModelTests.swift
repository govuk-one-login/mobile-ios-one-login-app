import GDSAnalytics
@testable import OneLogin
import XCTest

@MainActor
final class HomeTabViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: HomeTabViewModel!
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        sut = HomeTabViewModel(analyticsService: mockAnalyticsService)
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        sut = nil
        
        super.tearDown()
    }
}

extension HomeTabViewModelTests {
    func test_title_contents() throws {
        XCTAssertEqual(sut.navigationTitle.stringKey, "app_homeTitle")
        XCTAssertTrue(sut.backButtonIsHidden)
    }
    
    func test_didAppear() throws {
        sut.isLoggedIn = true
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(id: HomeAnalyticsScreenID.homeScreen.rawValue,
                                screen: HomeAnalyticsScreen.homeScreen,
                                titleKey: "app_homeTitle")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged, screen.parameters)
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level2"] as? String, AppTaxonomy.home.rawValue)
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level3"] as? String, "undefined")
    }
}
