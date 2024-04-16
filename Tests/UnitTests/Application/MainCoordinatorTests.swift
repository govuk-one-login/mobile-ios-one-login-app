import GDSCommon
@testable import OneLogin
import XCTest

@MainActor
final class MainCoordinatorTests: XCTestCase {
    var mockWindowManager: MockWindowManager!
    var tabBarController: UITabBarController!
    var mockAnalyticsService: MockAnalyticsService!
    var mockAnalyticsPreferenceStore: MockAnalyticsPreferenceStore!
    var mockAnalyticsCenter: MockAnalyticsCenter!
    var mockSecureStore: MockSecureStoreService!
    var mockDefaultStore: MockDefaultsStore!
    var mockUserStore: MockUserStore!
    var sut: MainCoordinator!
    
    var evaluateRevisitActionCalled = false
    
    override func setUp() {
        super.setUp()
        
        mockWindowManager = MockWindowManager(appWindow: UIWindow())
        tabBarController = .init()
        mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsPreferenceStore = MockAnalyticsPreferenceStore()
        mockAnalyticsCenter = MockAnalyticsCenter(analyticsService: mockAnalyticsService,
                                                  analyticsPreferenceStore: mockAnalyticsPreferenceStore)
        mockSecureStore = MockSecureStoreService()
        mockDefaultStore = MockDefaultsStore()
        mockUserStore = MockUserStore(secureStoreService: mockSecureStore,
                                      defaultsStore: mockDefaultStore)
        mockWindowManager.appWindow.rootViewController = tabBarController
        mockWindowManager.appWindow.makeKeyAndVisible()
        sut = MainCoordinator(windowManager: mockWindowManager,
                              root: tabBarController,
                              analyticsCenter: mockAnalyticsCenter,
                              userStore: mockUserStore)
    }
    
    override func tearDown() {
        mockWindowManager = nil
        tabBarController = nil
        mockAnalyticsService = nil
        mockAnalyticsPreferenceStore = nil
        mockAnalyticsCenter = nil
        mockSecureStore = nil
        mockDefaultStore = nil
        mockUserStore = nil
        sut = nil
        
        evaluateRevisitActionCalled = false
        
        super.tearDown()
    }
}

extension MainCoordinatorTests {
    func test_launchLoginCoordinator() throws {
        // WHEN the MainCoordinator is started
        sut.start()
        // THEN the MainCoordinator should have child coordinators
        XCTAssertEqual(sut.childCoordinators.count, 4)
        XCTAssertTrue(sut.childCoordinators[0] is HomeCoordinator)
        XCTAssertTrue(sut.childCoordinators[1] is WalletCoordinator)
        XCTAssertTrue(sut.childCoordinators[2] is ProfileCoordinator)
        XCTAssertTrue(sut.childCoordinators[3] is LoginCoordinator)
    }
    
    func test_evaluateRevisit_returningAuthenticatedUser() throws {
        // GIVEN the secure store has an access token saved and defaults store has the access token expiry saved
        try mockSecureStore.saveItem(item: "testAccessToken", itemName: .accessToken)
        mockDefaultStore.set(Date() + 60, forKey: .accessTokenExpiry)
        // WHEN the MainCoordinator's evaluateRevisit method is called with an action
        sut.evaluateRevisit { evaluateRevisitActionCalled = true }
        // THEN the access token is read from the token holder and the action is called
        XCTAssertEqual(sut.tokenHolder.accessToken, "testAccessToken")
        XCTAssertTrue(evaluateRevisitActionCalled)
    }
    
    func test_evaluateRevisit_accessTokenNil() throws {
        // GIVEN access token has not been stored anywhere
        // WHEN the MainCoordinator's evaluateRevisit method is called with an action
        sut.evaluateRevisit { evaluateRevisitActionCalled = true }
        // THEN the action is called
        XCTAssertTrue(evaluateRevisitActionCalled)
    }
    
    func test_evaluateRevisit_accessTokenNotNil() throws {
        // GIVEN access token has been stored in the token holder
        sut.tokenHolder.accessToken = "testAccessToken"
        // WHEN the MainCoordinator's evaluateRevisit method is called with an action
        sut.evaluateRevisit { evaluateRevisitActionCalled = true }
        // THEN the access token is removed from the token holder and the action is called
        XCTAssertNil(sut.tokenHolder.accessToken)
        XCTAssertTrue(evaluateRevisitActionCalled)
    }
    
    func test_didRegainFocus_fromLoginCoordinator() throws {
        // GIVEN access token has been stored in the token holder
        sut.tokenHolder.accessToken = "testAccessToken"
        let mockUserStore = UserStorage(secureStoreService: mockSecureStore,
                                        defaultsStore: mockDefaultStore)
        let loginCoordinator = LoginCoordinator(windowManager: mockWindowManager,
                                                root: UINavigationController(),
                                                analyticsCenter: mockAnalyticsCenter,
                                                networkMonitor: MockNetworkMonitor(),
                                                userStore: mockUserStore,
                                                tokenHolder: TokenHolder())
        // WHEN the MainCoordinator didRegainFocus from the LoginCoordinator
        sut.didRegainFocus(fromChild: loginCoordinator)
        // THEN no coordinator should be launched
        XCTAssertEqual(sut.childCoordinators.count, 0)
        // THEN the token holders bearer token should have the access token
        XCTAssertEqual(sut.tokenHolder.bearerToken, "testAccessToken")
        // THEN the network client should be initialised
        XCTAssertNotNil(sut.networkClient)
    }
}
