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
    var mockSecureStore: MockSecureStoreService!
    var mockDefaultStore: MockDefaultsStore!
    var sut: MainCoordinator!
    
    var evaluateRevisitActionCalled = false
    
    override func setUp() {
        super.setUp()

        window = .init()
        navigationController = .init()
        mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsPreferenceStore = MockAnalyticsPreferenceStore()
        mockAnalyticsCentre = AnalyticsCentre(analyticsService: mockAnalyticsService,
                                              analyticsPreferenceStore: mockAnalyticsPreferenceStore)
        mockSecureStore = MockSecureStoreService()
        mockDefaultStore = MockDefaultsStore()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        sut = MainCoordinator(window: window,
                              root: navigationController,
                              analyticsCentre: mockAnalyticsCentre,
                              secureStoreService: mockSecureStore,
                              defaultsStore: mockDefaultStore)
    }

    override func tearDown() {
        window = nil
        navigationController = nil
        mockAnalyticsService = nil
        mockAnalyticsPreferenceStore = nil
        mockAnalyticsCentre = nil
        mockSecureStore = nil
        mockDefaultStore = nil
        sut = nil
        
        evaluateRevisitActionCalled = false

        super.tearDown()
    }
}

extension MainCoordinatorTests {
    func test_launchLoginCoordinator() throws {
        // WHEN the LoginCoordinator is started
        sut.start()
        // THEN the LoginCoordinator should have an LoginCoordinator as it's only child coordinator
        XCTAssertEqual(sut.childCoordinators.count, 1)
        XCTAssertTrue(sut.childCoordinators[0] is LoginCoordinator)
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
    
    func test_launchTokenCoorindator_succeeds() throws {
        // GIVEN the token holder's access token has is not nil
        sut.tokenHolder.accessToken = "testAccessToken"
        // WHEN the LoginCoordinator's launchTokenCoordinator method is called
        sut.launchTokenCoordinator()
        // THEN the Token Coordinator should be launched
        XCTAssertEqual(sut.childCoordinators.count, 1)
        XCTAssertTrue(sut.childCoordinators[0] is TokenCoordinator)
    }
    
    func test_launchTokenCoorindator_fails() throws {
        // GIVEN the token holder's access token has is nil
        sut.launchTokenCoordinator()
        // WHEN the LoginCoordinator's launchTokenCoordinator method is called
        // THEN the Token Coordinator should not be launched
        XCTAssertEqual(sut.childCoordinators.count, 0)
    }
    
    func test_didRegainFocus_fromLoginCoordinator() throws {
        let mockUserStore = UserStorage(secureStoreService: mockSecureStore,
                                        defaultsStore: mockDefaultStore)
        // GIVEN the LoginCoordinator doesn't have an access token
        let loginCoordinator = LoginCoordinator(window: window,
                                                root: navigationController,
                                                analyticsCentre: mockAnalyticsCentre,
                                                userStore: mockUserStore,
                                                tokenHolder: TokenHolder())
        // WHEN the MainCoordinator didRegainFocus from the LoginCoordinator
        sut.didRegainFocus(fromChild: loginCoordinator)
        // THEN no coordinator should be launched
        XCTAssertEqual(sut.childCoordinators.count, 0)
    }
}
