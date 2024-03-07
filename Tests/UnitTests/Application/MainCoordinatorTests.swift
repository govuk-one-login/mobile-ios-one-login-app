import GDSCommon
@testable import OneLogin
import XCTest

@MainActor
final class MainCoordinatorTests: XCTestCase {
    var window: UIWindow!
    var navigationController: UINavigationController!
    var mockAnalyticsService: MockAnalyticsService!
    var mockAnalyticsPreferenceStore: MockAnalyticsPreferenceStore!
    var mockAnalyticsCentre: AnalyticsCentral!
    var sut: MainCoordinator!
    
    override func setUp() {
        super.setUp()

        window = .init()
        navigationController = .init()
        mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsPreferenceStore = MockAnalyticsPreferenceStore()
        mockAnalyticsCentre = AnalyticsCentre(analyticsService: mockAnalyticsService,
                                              analyticsPreferenceStore: mockAnalyticsPreferenceStore)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        sut = MainCoordinator(window: window,
                              root: navigationController,
                              analyticsCentre: mockAnalyticsCentre)
    }

    override func tearDown() {
        window = nil
        navigationController = nil
        mockAnalyticsService = nil
        mockAnalyticsPreferenceStore = nil
        mockAnalyticsCentre = nil
        sut = nil

        super.tearDown()
    }
}

/*
 TESTS
 - MainCoordinator starts and launches LoginCoordinator
 - MainCoordinator is handed back from LoginCoordinator and launches TokenCoordinator
 */

extension MainCoordinatorTests {
    func test_launchLoginCoordinator() throws {
        // WHEN the LoginCoordinator is started
        sut.start()
        // THEN the LoginCoordinator should have an AuthenticationCoordinator as it's only child coordinator
        XCTAssertEqual(sut.childCoordinators.count, 1)
        XCTAssertTrue(sut.childCoordinators[0] is LoginCoordinator)
    }
    
    func test_launchTokenCoorindator_succeeds() throws {
        sut.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
        sut.launchTokenCoordinator()
        XCTAssertEqual(sut.childCoordinators.count, 1)
        XCTAssertTrue(sut.childCoordinators[0] is TokenCoordinator)
    }
    
    func test_launchTokenCoorindator_fails() throws {
        sut.launchTokenCoordinator()
        XCTAssertEqual(sut.childCoordinators.count, 0)
    }
    
    func test_didRegainFocus_fromLoginCoordinator() throws {
        sut.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
        let loginCoordinator = LoginCoordinator(window: window,
                                                root: navigationController,
                                                analyticsCentre: mockAnalyticsCentre,
                                                secureStoreService: MockSecureStoreService(),
                                                defaultStore: MockDefaultsStore(),
                                                tokenHolder: TokenHolder())
        sut.didRegainFocus(fromChild: loginCoordinator)
        XCTAssertEqual(sut.childCoordinators.count, 1)
        XCTAssertTrue(sut.childCoordinators[0] is TokenCoordinator)
    }
}
