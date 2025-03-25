import GDSAnalytics
import Networking
@testable import OneLogin
import XCTest

@MainActor
final class SceneLifecycleTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var mockAnalyticsPreferenceStore: MockAnalyticsPreferenceStore!
    var mockSessionManager: MockSessionManager!
    var mockTabManagerCoordinator: TabManagerCoordinator!
    var sut: MockSceneDelegate!
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsPreferenceStore = MockAnalyticsPreferenceStore()
        mockSessionManager = MockSessionManager()
        mockTabManagerCoordinator = TabManagerCoordinator(root: UITabBarController(),
                                                          analyticsService: mockAnalyticsService,
                                                          analyticsPreferenceStore: mockAnalyticsPreferenceStore,
                                                          networkClient: NetworkClient(),
                                                          sessionManager: mockSessionManager)
        sut = MockSceneDelegate(coordinator: mockTabManagerCoordinator,
                                analyticsService: mockAnalyticsService)
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        mockAnalyticsPreferenceStore = nil
        mockSessionManager = nil
        mockTabManagerCoordinator = nil
        sut = nil
        
        super.tearDown()
    }
}

extension SceneLifecycleTests {
    func test_splashscreen_analytics() throws {
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.trackSplashScreen()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(id: IntroAnalyticsScreenID.splash.rawValue,
                                screen: IntroAnalyticsScreen.splash,
                                titleKey: "one login splash screen")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged, screen.parameters)
    }
}
