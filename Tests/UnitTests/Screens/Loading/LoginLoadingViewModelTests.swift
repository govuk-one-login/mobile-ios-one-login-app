import GDSAnalytics
@testable import OneLogin
import XCTest

@MainActor
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
        
        super.tearDown()
    }
}

extension LoginLoadingViewModelTests {
    func test_page() {
        XCTAssertEqual(sut.loadingLabelKey.stringKey, "app_loadingBody")
    }
    
    func test_didAppear() {
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(id: IntroAnalyticsScreenID.loginLoadingScreen.rawValue,
                                screen: IntroAnalyticsScreen.loginLoadingScreen,
                                titleKey: "app_loadingBody")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged, screen.parameters)
    }
}
