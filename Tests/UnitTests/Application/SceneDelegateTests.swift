import GAnalytics
import Logging
@testable import OneLogin
import XCTest

class MockSceneDelegate: SceneLifecycle {
    var windowScene: UIWindowScene?
    var coordinator: MainCoordinator?
    var analyticsService: AnalyticsService
    var unlockWindow: UIWindow?
    
    init(coordinator: MainCoordinator?,
         analyticsService: AnalyticsService) {
        let scenes = UIApplication.shared.connectedScenes
        let windowScenes = scenes.first as? UIWindowScene
        self.windowScene = windowScenes
        self.coordinator = coordinator
        self.analyticsService = analyticsService
    }
}

@MainActor
final class SceneDelegateTests: XCTestCase {
    var mockMainCoordinator: MainCoordinator!
    var mockAnalyticsService: MockAnalyticsService!
    var mockAnalyticsPreferenceStore: MockAnalyticsPreferenceStore!
    var sut: MockSceneDelegate!
    
    override func setUp() {
        super.setUp()
        
        mockMainCoordinator = MainCoordinator(window: UIWindow(),
                                              root: UINavigationController(),
                                              analyticsCentre: AnalyticsCentre(analyticsService: mockAnalyticsService,
                                                                               analyticsPreferenceStore: mockAnalyticsPreferenceStore))
        mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsPreferenceStore = MockAnalyticsPreferenceStore()
        sut = MockSceneDelegate(coordinator: mockMainCoordinator,
                                analyticsService: mockAnalyticsService)
    }
    
    override func tearDown() {
        mockMainCoordinator = nil
        mockAnalyticsService = nil
        mockAnalyticsPreferenceStore = nil
        sut = nil
        
        super.tearDown()
    }
}

extension SceneDelegateTests {
    func test_displayUnlockScreen() throws {
        sut.displayUnlockScreen()
    }
}
