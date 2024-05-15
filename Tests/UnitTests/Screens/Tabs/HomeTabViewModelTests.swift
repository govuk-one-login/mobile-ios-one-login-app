import GDSAnalytics
@testable import OneLogin
import XCTest

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
        let screen = ScreenView(id: TabAnalyticsScreenID.home.rawValue,
                                screen: TabAnalyticsScreen.home,
                                titleKey: "app_homeTitle")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged["title"], screen.parameters["title"])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged["screen_id"], screen.parameters["screen_id"])
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level2"] as? String, "home")
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level3"] as? String, "undefined")
    }
}
