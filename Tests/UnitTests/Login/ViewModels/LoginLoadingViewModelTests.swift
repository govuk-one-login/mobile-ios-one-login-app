import GDSAnalytics
#if NOW
@testable import OneLoginNOW
#else
@testable import OneLogin
#endif

import XCTest

final class LoginLoadingViewModelTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var sut: LoginLoadingViewModel!

    override func setUp() {
        super.setUp()

        mockAnalyticsService = MockAnalyticsService()
        sut = LoginLoadingViewModel(analyticsService: mockAnalyticsService)
    }

    override func tearDown() {
        mockAnalyticsService = nil
        sut =  nil
    }
}

extension LoginLoadingViewModelTests {
    func test_label_contents() throws {
        XCTAssertEqual(sut.loadingLabelKey.stringKey, "app_loadingBody")
    }
    
    func test_didAppear() throws {
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(id: IntroAnalyticsScreenID.loginLoadingScreen.rawValue,
                                screen: IntroAnalyticsScreen.loginLoadingScreen,
                                titleKey: "app_loadingBody")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged["title"], screen.parameters["title"])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged["screen_id"], screen.parameters["screen_id"])
    }
}
