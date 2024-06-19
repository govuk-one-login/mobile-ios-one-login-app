import GDSAnalytics
import GDSCommon
@testable import OneLogin
import SecureStore
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
    var mockUserStore: UserStorage!
    var mockTokenVerifier: MockTokenVerifier!
    var mockURLOpener: MockURLOpener!
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
        mockUserStore = UserStorage(secureStoreService: mockSecureStore,
                                    defaultsStore: mockDefaultStore)
        mockURLOpener = MockURLOpener()
        mockWindowManager.appWindow.rootViewController = tabBarController
        mockWindowManager.appWindow.makeKeyAndVisible()
        mockTokenVerifier = MockTokenVerifier()
        sut = MainCoordinator(windowManager: mockWindowManager,
                              root: tabBarController,
                              analyticsCenter: mockAnalyticsCenter,
                              userStore: mockUserStore,
                              tokenVerifier: mockTokenVerifier)
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
        mockTokenVerifier = nil
        mockURLOpener = nil
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
        // GIVEN the secure store has a valid idToken saved and defaults store has the access token expiry saved
        try mockSecureStore.saveItem(item: MockJWKSResponse.idToken, itemName: .idToken)
        mockDefaultStore.set(Date() + 60, forKey: .accessTokenExpiry)
        // WHEN the MainCoordinator's evaluateRevisit method is called with an action
        sut.evaluateRevisit { self.evaluateRevisitActionCalled = true }
        // THEN the payload will be extracted from the idToken
        waitForTruth(self.sut.tokenHolder.idTokenPayload != nil, timeout: 20)
        XCTAssertTrue(evaluateRevisitActionCalled)
    }
    
    func test_evaluateRevisit_idTokenNil() throws {
        // GIVEN id token has not been stored anywhere
        // WHEN the MainCoordinator's evaluateRevisit method is called with an action
        sut.evaluateRevisit { self.evaluateRevisitActionCalled = true }
        // THEN the action is called
        waitForTruth(self.evaluateRevisitActionCalled == true, timeout: 20)
        XCTAssertTrue(sut.childCoordinators.first is LoginCoordinator)
    }
    
    func test_evaluateRevisit_idTokenExtractedFailed() throws {
        // GIVEN the secure store has a valid idToken saved and defaults store has the access token expiry saved
        try mockSecureStore.saveItem(item: MockJWKSResponse.idToken, itemName: .idToken)
        mockDefaultStore.set(Date() + 60, forKey: .accessTokenExpiry)
        // WHEN the MainCoordinator's evaluateRevisit method is called with an action, and the extraction fails
        mockTokenVerifier.extractionError = JWTVerifierError.invalidJWTFormat
        sut.evaluateRevisit { self.evaluateRevisitActionCalled = true }
        waitForTruth(self.evaluateRevisitActionCalled == true, timeout: 20)
        // THEN the access token is removed from the token holder, the id token is removed
        // and the access token expiry is cleared
        XCTAssertNil(sut.tokenHolder.accessToken)
        XCTAssertThrowsError(try mockSecureStore.readItem(itemName: .idToken))
        XCTAssertNil(mockDefaultStore.value(forKey: .accessTokenExpiry))
        // AND login will be shown
        XCTAssertTrue(sut.childCoordinators.first is LoginCoordinator)
    }
    
    func test_evaluateRevisit_accessTokenNotNil() throws {
        // GIVEN access token has been stored in the token holder
        sut.tokenHolder.accessToken = "testAccessToken"
        // WHEN the MainCoordinator's evaluateRevisit method is called with an action
        sut.evaluateRevisit { self.evaluateRevisitActionCalled = true }
        waitForTruth(self.evaluateRevisitActionCalled == true, timeout: 20)
        // THEN the access token is removed from the token holder and the action is called
        // AND login will be shown
        XCTAssertNil(sut.tokenHolder.accessToken)
        XCTAssertTrue(sut.childCoordinators.first is LoginCoordinator)
        XCTAssertTrue(evaluateRevisitActionCalled)
    }
    
    func test_evaluateRevisit_secureStoreError() throws {
        // GIVEN the secure store has a valid idToken saved and defaults store has the access token expiry saved
        try mockSecureStore.saveItem(item: MockJWKSResponse.idToken, itemName: .idToken)
        mockDefaultStore.set(Date() + 60, forKey: .accessTokenExpiry)
        // WHEN the MainCoordinator's evaluateRevisit method is called with an action, and the secure store read fails
        mockSecureStore.errorFromReadItem = SecureStoreError.cantRetrieveKey
        sut.evaluateRevisit { self.evaluateRevisitActionCalled = true }
        waitForTruth(self.evaluateRevisitActionCalled == true, timeout: 20)
        // THEN the access token and the access token expiry is cleared
        XCTAssertNil(sut.tokenHolder.accessToken)
        XCTAssertNil(mockDefaultStore.value(forKey: .accessTokenExpiry))
        // AND login will be shown
        XCTAssertTrue(sut.childCoordinators.first is LoginCoordinator)
    }
    
    func test_evaluateRevisit_localAuth_fails() throws {
        // GIVEN the secure store has a valid idToken saved and defaults store has the access token expiry saved
        try mockSecureStore.saveItem(item: MockJWKSResponse.idToken, itemName: .idToken)
        mockDefaultStore.set(Date() + 60, forKey: .accessTokenExpiry)
        // WHEN the MainCoordinator's evaluateRevisit method is called with an action, and local auth fails
        // NOTE: cantDecryptData is the error secure store throws when local auth fails
        mockSecureStore.errorFromReadItem = SecureStoreError.cantDecryptData
        sut.evaluateRevisit { self.evaluateRevisitActionCalled = true }
        // THEN the idToken will be nil
        waitForTruth(self.sut.tokenHolder.idTokenPayload == nil, timeout: 20)
        // THEN the unlock window will not have been dismissed
        XCTAssertFalse(mockWindowManager.hideUnlockWindowCalled)
        // THEN the LoginCoordinator will NOT be presented
        XCTAssertEqual(sut.childCoordinators.count, 0)
    }
    
    func test_didSelect_tabBarItem_home() throws {
        // GIVEN the MainCoordinator has started and added it's tab bar items
        sut.start()
        guard let homeVC = tabBarController.viewControllers?[0] else {
            XCTFail("HomeVC not added as child viewcontroller to tabBarController")
            return
        }
        // WHEN the tab bar controller's delegate method didSelect is called with the home view controller
        tabBarController.delegate?.tabBarController?(tabBarController, didSelect: homeVC)
        // THEN the home view controller's tab bar event is sent
        let iconEvent = IconEvent(textKey: "home")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [iconEvent.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["type"], iconEvent.type.rawValue)
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["text"], iconEvent.text)
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level2"] as? String, "login")
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level3"] as? String, "undefined")
    }
    
    func test_didSelect_tabBarItem_wallet() throws {
        // GIVEN the MainCoordinator has started and added it's tab bar items
        sut.start()
        guard let walletVC = tabBarController.viewControllers?[1] else {
            XCTFail("WalletVC not added as child viewcontroller to tabBarController")
            return
        }
        // WHEN the tab bar controller's delegate method didSelect is called with the wallet view controller
        tabBarController.delegate?.tabBarController?(tabBarController, didSelect: walletVC)
        // THEN the wallet view controller's tab bar event is sent
        let iconEvent = IconEvent(textKey: "wallet")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [iconEvent.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["type"], iconEvent.type.rawValue)
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["text"], iconEvent.text)
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level2"] as? String, "login")
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level3"] as? String, "undefined")
    }
    
    func test_didSelect_tabBarItem_profile() throws {
        // GIVEN the MainCoordinator has started and added it's tab bar items
        sut.start()
        guard let profileVC = tabBarController.viewControllers?[2] else {
            XCTFail("ProfileVC not added as child viewcontroller to tabBarController")
            return
        }
        // WHEN the tab bar controller's delegate method didSelect is called with the profile view controller
        tabBarController.delegate?.tabBarController?(tabBarController, didSelect: profileVC)
        // THEN the profile view controller's tab bar event is sent
        let iconEvent = IconEvent(textKey: "profile")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [iconEvent.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["type"], iconEvent.type.rawValue)
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["text"], iconEvent.text)
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level2"] as? String, "login")
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level3"] as? String, "undefined")
    }
    
    func test_didRegainFocus_fromLoginCoordinator_withBearerToken() throws {
        // GIVEN access token has been stored in the token holder
        sut.tokenHolder.accessToken = "testAccessToken"
        let mockUserStore = UserStorage(secureStoreService: mockSecureStore,
                                        defaultsStore: mockDefaultStore)
        let loginCoordinator = LoginCoordinator(windowManager: mockWindowManager,
                                                root: UINavigationController(),
                                                analyticsCenter: mockAnalyticsCenter,
                                                userStore: mockUserStore,
                                                networkMonitor: MockNetworkMonitor(),
                                                tokenHolder: TokenHolder())
        // WHEN the MainCoordinator didRegainFocus from the LoginCoordinator
        sut.didRegainFocus(fromChild: loginCoordinator)
        // THEN no coordinator should be launched
        XCTAssertEqual(sut.childCoordinators.count, 0)
        // THEN the token holders bearer token should have the access token
        XCTAssertEqual(try sut.tokenHolder.bearerToken, "testAccessToken")
    }
    
    func test_didRegainFocus_fromLoginCoordinator_withoutBearerToken() throws {
        let mockUserStore = UserStorage(secureStoreService: mockSecureStore,
                                        defaultsStore: mockDefaultStore)
        let loginCoordinator = LoginCoordinator(windowManager: mockWindowManager,
                                                root: UINavigationController(),
                                                analyticsCenter: mockAnalyticsCenter,
                                                userStore: mockUserStore,
                                                networkMonitor: MockNetworkMonitor(),
                                                tokenHolder: TokenHolder())
        // WHEN the MainCoordinator didRegainFocus from the LoginCoordinator
        sut.didRegainFocus(fromChild: loginCoordinator)
        // THEN no coordinator should be launched
        XCTAssertEqual(sut.childCoordinators.count, 0)
        // THEN the token holders bearer token should have the access token
        do {
            _ = try sut.tokenHolder.bearerToken
            XCTFail("Should throw TokenError error")
        } catch {
            XCTAssertTrue(error is TokenError)
        }
    }
    
    func test_didRegainFocus_fromProfileCoordinator() throws {
        let profileCoordinator = ProfileCoordinator(analyticsCenter: mockAnalyticsCenter,
                                                    userStore: mockUserStore,
                                                    tokenHolder: TokenHolder(),
                                                    urlOpener: mockURLOpener)
        // WHEN the MainCoordinator didRegainFocus from ProfileCoordinator (on user sign out)
        sut.didRegainFocus(fromChild: profileCoordinator)
        // Then the LoginCoordinator should be launched
        XCTAssertEqual(sut.childCoordinators.count, 1)
        XCTAssertTrue(sut.childCoordinators[0] is LoginCoordinator)
    }
    
    func test_performChildCleanup_fromLoginCoordinator() throws {
        let mockUserStore = UserStorage(secureStoreService: mockSecureStore,
                                        defaultsStore: mockDefaultStore)
        let loginCoordinator = LoginCoordinator(windowManager: mockWindowManager,
                                                root: UINavigationController(),
                                                analyticsCenter: mockAnalyticsCenter,
                                                userStore: mockUserStore,
                                                networkMonitor: MockNetworkMonitor(),
                                                tokenHolder: TokenHolder())
        // WHEN the MainCoordinator performChildCleanup from the LoginCoordinator
        sut.performChildCleanup(child: loginCoordinator)
        // THEN no coordinator should be launched
        XCTAssertFalse(loginCoordinator.root.isBeingPresented)
    }
}
