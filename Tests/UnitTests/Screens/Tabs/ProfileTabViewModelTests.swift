import GDSAnalytics
@testable import OneLogin
import XCTest

@MainActor
final class ProfileTabViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: ProfileTabViewModel!
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        sut = ProfileTabViewModel(analyticsService: mockAnalyticsService)
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        sut = nil
        
        super.tearDown()
    }
}

extension ProfileTabViewModelTests {
    func test_page() {
        XCTAssertEqual(sut.navigationTitle.stringKey, "app_profileTitle")
        XCTAssertNil(sut.rightBarButtonTitle)
        XCTAssertTrue(sut.backButtonIsHidden)
    }
    
    func test_didAppear() {
        sut.isLoggedIn = true
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(id: ProfileAnalyticsScreenID.profileScreen.rawValue,
                                screen: ProfileAnalyticsScreen.profileScreen,
                                titleKey: "app_profileTitle")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged, screen.parameters)
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level2"] as? String, AppTaxonomy.profile.rawValue)
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level3"] as? String, "my profile")
    }
}
