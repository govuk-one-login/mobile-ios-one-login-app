import GDSAnalytics
@testable import OneLogin
import XCTest

@MainActor
final class SceneLifecycleTests: XCTestCase {
    var mockWindowManager: MockWindowManager!
    var mockAnalyticsService: MockAnalyticsService!
    var mockAnalyticsPreferenceStore: MockAnalyticsPreferenceStore!
    var mockAnalyticsCenter: MockAnalyticsCenter!
    var mockSessionManager: MockSessionManager!
    var mockMainCoordinator: MainCoordinator!
    var sut: MockSceneDelegate!
    
    override func setUp() {
        super.setUp()
        mockWindowManager = MockWindowManager(appWindow: UIWindow())
        mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsPreferenceStore = MockAnalyticsPreferenceStore()
        mockAnalyticsCenter = MockAnalyticsCenter(analyticsService: mockAnalyticsService,
                                                  analyticsPreferenceStore: mockAnalyticsPreferenceStore)
        mockSessionManager = MockSessionManager()
        mockMainCoordinator = MainCoordinator(windowManager: mockWindowManager,
                                              root: UITabBarController(),
                                              analyticsCenter: mockAnalyticsCenter,
                                              sessionManager: mockSessionManager)
        sut = MockSceneDelegate(coordinator: mockMainCoordinator,
                                analyticsService: mockAnalyticsService,
                                windowManager: mockWindowManager)
    }
    
    override func tearDown() {
        mockWindowManager = nil
        mockAnalyticsService = nil
        mockAnalyticsPreferenceStore = nil
        mockAnalyticsCenter = nil
        mockSessionManager = nil
        mockMainCoordinator = nil
        sut = nil
        
        super.tearDown()
    }
}

extension SceneLifecycleTests {
    func test_displayUnlockScreen() throws {
        sut.displayUnlockScreen()
        XCTAssertTrue(mockWindowManager.displayUnlockWindowCalled)

    }
    
    func test_splashscreen_analytics() throws {
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.trackSplashScreen(mockAnalyticsCenter.analyticsService)
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(id: IntroAnalyticsScreenID.splashScreen.rawValue,
                                screen: IntroAnalyticsScreen.splashScreen,
                                titleKey: "one login splash screen")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged["title"], screen.parameters["title"])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged["screen_id"], screen.parameters["screen_id"])

    }
}
