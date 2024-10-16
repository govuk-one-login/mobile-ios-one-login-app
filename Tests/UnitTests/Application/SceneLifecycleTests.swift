import GDSAnalytics
import Networking
@testable import OneLogin
import XCTest

@MainActor
final class SceneLifecycleTests: XCTestCase {
    var window: UIWindow!
    var mockAnalyticsService: MockAnalyticsService!
    var mockAnalyticsPreferenceStore: MockAnalyticsPreferenceStore!
    var mockAnalyticsCenter: MockAnalyticsCenter!
    var mockSessionManager: MockSessionManager!
    var mockWalletAvailabilityService: MockWalletAvailabilityService!
    var mockTabManagerCoordinator: TabManagerCoordinator!
    var sut: MockSceneDelegate!
    
    override func setUp() {
        super.setUp()
        window = UIWindow()
        mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsPreferenceStore = MockAnalyticsPreferenceStore()
        mockAnalyticsCenter = MockAnalyticsCenter(analyticsService: mockAnalyticsService,
                                                  analyticsPreferenceStore: mockAnalyticsPreferenceStore)
        mockSessionManager = MockSessionManager()
        mockWalletAvailabilityService = MockWalletAvailabilityService()
        mockTabManagerCoordinator = TabManagerCoordinator(appWindow: window,
                                              root: UITabBarController(),
                                              analyticsCenter: mockAnalyticsCenter,
                                              networkClient: NetworkClient(),
                                              sessionManager: mockSessionManager,
                                              walletAvailabilityService: mockWalletAvailabilityService)
        sut = MockSceneDelegate(coordinator: mockTabManagerCoordinator,
                                analyticsService: mockAnalyticsService)
    }
    
    override func tearDown() {
        window = nil
        mockAnalyticsService = nil
        mockAnalyticsPreferenceStore = nil
        mockAnalyticsCenter = nil
        mockSessionManager = nil
        mockTabManagerCoordinator = nil
        mockWalletAvailabilityService = nil
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
