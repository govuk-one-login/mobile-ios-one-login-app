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
final class SceneLifecycleTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var mockAnalyticsPreferenceStore: MockAnalyticsPreferenceStore!
    var mockAnalyticsCenter: MockAnalyticsCenter!
    var mockSecureStore: MockSecureStoreService!
    var mockDefaultStore: MockDefaultsStore!
    var mockUserStore: MockUserStore!
    var mockMainCoordinator: MainCoordinator!
    var sut: MockSceneDelegate!
    
    override func setUp() {
        super.setUp()
        mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsPreferenceStore = MockAnalyticsPreferenceStore()
        mockAnalyticsCenter = MockAnalyticsCenter(analyticsService: mockAnalyticsService,
                                                  analyticsPreferenceStore: mockAnalyticsPreferenceStore)
        mockSecureStore = MockSecureStoreService()
        mockDefaultStore = MockDefaultsStore()
        mockUserStore = MockUserStore(secureStoreService: mockSecureStore,
                                      defaultsStore: mockDefaultStore)
        mockMainCoordinator = MainCoordinator(window: UIWindow(),
                                              root: UITabBarController(),
                                              analyticsCenter: mockAnalyticsCenter,
                                              userStore: mockUserStore)
        sut = MockSceneDelegate(coordinator: mockMainCoordinator,
                                analyticsService: mockAnalyticsService)
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        mockAnalyticsPreferenceStore = nil
        mockAnalyticsCenter = nil
        mockMainCoordinator = nil
        sut = nil
        
        super.tearDown()
    }
}

extension SceneLifecycleTests {
    func test_displayUnlockScreen() throws {
        sut.displayUnlockScreen()
        XCTAssertNotNil(sut.unlockWindow)
        XCTAssertTrue(sut.unlockWindow?.rootViewController is UnlockScreenViewController)
        XCTAssertEqual(sut.unlockWindow?.windowLevel, .alert)
    }
    
    func test_promptToUnlock() throws {
        sut.promptToUnlock()
        XCTAssertNil(sut.unlockWindow)
    }
}
