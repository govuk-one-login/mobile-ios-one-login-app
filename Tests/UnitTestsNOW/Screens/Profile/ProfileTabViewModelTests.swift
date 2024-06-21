import GDSAnalytics
@testable import OneLoginNOW
import XCTest

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
    func test_title_contents() throws {
        XCTAssertEqual(sut.navigationTitle.stringKey, "app_profileTitle")
        XCTAssertTrue(sut.backButtonIsHidden)
    }
    
    func test_didAppear() throws {
        sut.isLoggedIn = true
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(id: ProfileAnalyticsScreenID.profileScreen.rawValue,
                                screen: ProfileAnalyticsScreen.profileScreen,
                                titleKey: "app_profileTitle")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged["title"], screen.parameters["title"])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged["screen_id"], screen.parameters["screen_id"])
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level2"] as? String, "profile")
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level3"] as? String, "my profile")
    }
}
