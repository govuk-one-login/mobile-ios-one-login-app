import GDSAnalytics
@testable import OneLogin
import XCTest

@MainActor
final class SceneLifecycleTests: XCTestCase {
    var mockWindowManager: MockWindowManager!
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
        mockWindowManager = MockWindowManager(appWindow: UIWindow())
        mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsPreferenceStore = MockAnalyticsPreferenceStore()
        mockAnalyticsCenter = MockAnalyticsCenter(analyticsService: mockAnalyticsService,
                                                  analyticsPreferenceStore: mockAnalyticsPreferenceStore)
        mockSecureStore = MockSecureStoreService()
        mockDefaultStore = MockDefaultsStore()
        mockUserStore = MockUserStore(secureStoreService: mockSecureStore,
                                      defaultsStore: mockDefaultStore)
        mockMainCoordinator = MainCoordinator(windowManager: mockWindowManager,
                                              root: UITabBarController(),
                                              analyticsCenter: mockAnalyticsCenter,
                                              userStore: mockUserStore)
        sut = MockSceneDelegate(coordinator: mockMainCoordinator,
                                analyticsService: mockAnalyticsService,
                                windowManager: mockWindowManager)
    }
    
    override func tearDown() {
        mockWindowManager = nil
        mockAnalyticsService = nil
        mockAnalyticsPreferenceStore = nil
        mockAnalyticsCenter = nil
        mockSecureStore = nil
        mockDefaultStore = nil
        mockUserStore = nil
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
    
    func test_promptToUnlock() throws {
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 0)
        sut.promptToUnlock()
        XCTAssertEqual(mockAnalyticsService.screensVisited.count, 1)
        let screen = ScreenView(id: BiometricEnrollmentAnalyticsScreenID.unlockScreen.rawValue,
                                screen: BiometricEnrollmentAnalyticsScreen.unlockScreen,
                                titleKey: "one login unlock screen")
        XCTAssertEqual(mockAnalyticsService.screensVisited, [screen.name])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged["title"], screen.parameters["title"])
        XCTAssertEqual(mockAnalyticsService.screenParamsLogged["screen_id"], screen.parameters["screen_id"])
        XCTAssertTrue(mockWindowManager.hideUnlockWindowCalled)
    }
}
