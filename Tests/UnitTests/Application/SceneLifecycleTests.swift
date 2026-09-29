import GDSAnalytics
import Networking
@testable import OneLogin
import Testing
import UIKit

@MainActor
struct SceneLifecycleTests {
    var mockAnalyticsService: MockAnalyticsService!
    var mockSessionManager: MockSessionManager!
    var mockTabManagerCoordinator: TabManagerCoordinator!
    var sut: MockSceneDelegate!
    
    init() {
        mockAnalyticsService = MockAnalyticsService()
        mockSessionManager = MockSessionManager()
        mockTabManagerCoordinator = TabManagerCoordinator(root: UITabBarController(),
                                                          analyticsService: mockAnalyticsService,
                                                          networkingService: NetworkClient(),
                                                          sessionManager: mockSessionManager)
        sut = MockSceneDelegate(coordinator: mockTabManagerCoordinator,
                                analyticsService: mockAnalyticsService)
    }
}

extension SceneLifecycleTests {
    @Test
    func test_splashscreen_analytics() {
        #expect(mockAnalyticsService.screenViews.count == 0)
        sut.trackSplashScreen()
        #expect(mockAnalyticsService.screenViews.count == 1)
        let screen = ScreenView(id: IntroAnalyticsScreenID.splash.rawValue,
                                screen: IntroAnalyticsScreen.splash,
                                titleKey: "one login splash screen")
        #expect(mockAnalyticsService.screenViews as? [ScreenView] == [screen])
        #expect(mockAnalyticsService.screenParamsLogged == screen.parameters)
    }
}
