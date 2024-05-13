import GDSAnalytics
@testable import OneLogin
import XCTest

final class HomeTabViewModelTests: XCTestCase {

    var mockAnalyticsService: MockAnalyticsService!
    var sut: HomeTabViewModel!
    var didUserLogIn: Bool = false

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
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        didUserLogIn = true
        sut.didAppear()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(id: TabAnalyticsScreenID.home.rawValue,
                                screen: TabAnalyticsScreen.home,
                                titleKey: "app_homeTitle")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged["title"], screen.parameters["title"])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged["screen_id"], screen.parameters["screen_id"])
    }
}
