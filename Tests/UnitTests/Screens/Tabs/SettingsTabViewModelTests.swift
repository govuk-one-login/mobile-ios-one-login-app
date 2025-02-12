import GDSAnalytics
@testable import OneLogin
import XCTest

@MainActor
final class SettingsTabViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: SettingsTabViewModel!
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        sut = SettingsTabViewModel(analyticsService: mockAnalyticsService)
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        sut = nil
        
        super.tearDown()
    }
}

extension SettingsTabViewModelTests {
    func test_page() {
        XCTAssertEqual(sut.navigationTitle.stringKey, "app_settingsTitle")
        XCTAssertNil(sut.rightBarButtonTitle)
        XCTAssertTrue(sut.backButtonIsHidden)
    }
    
    func test_didAppear() {
        sut.isLoggedIn = true
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(id: SettingsAnalyticsScreenID.settingsScreen.rawValue,
                                screen: SettingsAnalyticsScreen.settingsScreen,
                                titleKey: "app_settingsTitle")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged, screen.parameters)
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level2"] as? String, AppTaxonomy.settings.rawValue)
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level3"] as? String, "my settings")
    }
}
