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
    var mockMainCoordinator: MainCoordinator!
    var sut: MockSceneDelegate!
    
    override func setUp() {
        super.setUp()
        mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsPreferenceStore = MockAnalyticsPreferenceStore()
        mockMainCoordinator = MainCoordinator(window: UIWindow(),
                                              root: UINavigationController(),
                                              analyticsCentre: AnalyticsCentre(analyticsService: mockAnalyticsService,
                                                                               analyticsPreferenceStore: mockAnalyticsPreferenceStore))

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

extension SceneLifecycleTests {
    func test_displayUnlockScreen() throws {
        sut.displayUnlockScreen()
        XCTAssertNotNil(sut.unlockWindow)
        XCTAssertTrue(sut.unlockWindow?.rootViewController is UnlockScreenViewController)
        XCTAssertEqual(sut.unlockWindow?.windowLevel, .alert)
    }
    
    func test_dismissUnlockScreen() throws {
        sut.dismissUnlockScreen()
        XCTAssertNil(sut.unlockWindow)
    }
}
