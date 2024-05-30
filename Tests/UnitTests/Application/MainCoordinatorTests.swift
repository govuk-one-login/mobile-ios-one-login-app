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
    var mockUserStore: MockUserStore!
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
        mockUserStore = MockUserStore(secureStoreService: mockSecureStore,
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
    
    func test_evaluateRevisit_accessTokenNil() throws {
        // GIVEN access token has not been stored anywhere
        // WHEN the MainCoordinator's evaluateRevisit method is called with an action
        sut.evaluateRevisit { self.evaluateRevisitActionCalled = true }
        // THEN the action is called
        waitForTruth(self.evaluateRevisitActionCalled == true, timeout: 20)
    }
    
    func test_evaluateRevisit_idTokenExtractedFailed() throws {
        // GIVEN the secure store has a valid idToken saved and defaults store has the access token expiry saved
        try mockSecureStore.saveItem(item: MockJWKSResponse.idToken, itemName: .idToken)
        mockDefaultStore.set(Date() + 60, forKey: .accessTokenExpiry)
        // WHEN the MainCoordinator's evaluateRevisit method is called with an action, and the extraction fails
        mockTokenVerifier.extractionFailed = true
        sut.evaluateRevisit { self.evaluateRevisitActionCalled = true }
        // THEN the access token and expiry will be set to nil
        waitForTruth(self.sut.tokenHolder.accessToken == nil, timeout: 20)
        XCTAssertNil(mockDefaultStore.value(forKey: .accessTokenExpiry))
        // AND the login will be shown
        XCTAssertTrue(sut.childCoordinators.first is LoginCoordinator)
    }
    
    func test_evaluateRevisit_accessTokenNotNil() throws {
        // GIVEN access token has been stored in the token holder
        sut.tokenHolder.accessToken = "testAccessToken"
        // WHEN the MainCoordinator's evaluateRevisit method is called with an action
        sut.evaluateRevisit { self.evaluateRevisitActionCalled = true }
        // THEN the access token is removed from the token holder and the action is called
        waitForTruth(self.sut.tokenHolder.accessToken == nil, timeout: 20)
        XCTAssertTrue(evaluateRevisitActionCalled)
    }
    
    func test_evaluateRevisit_secureStoreError() throws {
        // GIVEN the secure store has a valid idToken saved and defaults store has the access token expiry saved
        try mockSecureStore.saveItem(item: MockJWKSResponse.idToken, itemName: .idToken)
        mockDefaultStore.set(Date() + 60, forKey: .accessTokenExpiry)
        // WHEN the MainCoordinator's evaluateRevisit method is called with an action, and the secure store read fails
        mockSecureStore.errorFromReadItem = SecureStoreError.cantRetrieveKey
        sut.evaluateRevisit { self.evaluateRevisitActionCalled = true }
        // THEN the access token and expiry will be set to nil
        waitForTruth(self.sut.tokenHolder.accessToken == nil, timeout: 20)
        XCTAssertNil(mockDefaultStore.value(forKey: .accessTokenExpiry))
        // AND the login will be shown
        XCTAssertTrue(sut.childCoordinators.first is LoginCoordinator)
    }
    
    func test_didSelect_tabBarItem_home() throws {
        sut.start()
        guard let homeVC = tabBarController.viewControllers?[0] else {
            XCTFail("HomeVC not added as child viewcontroller to tabBarController")
            return
        }
        tabBarController.delegate?.tabBarController?(tabBarController, didSelect: homeVC)
        let iconEvent = IconEvent(textKey: "home")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [iconEvent.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["type"], iconEvent.type.rawValue)
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["text"], iconEvent.text)
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level2"] as? String, "login")
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level3"] as? String, "undefined")
    }
    
    func test_didSelect_tabBarItem_wallet() throws {
        sut.start()
        guard let walletVC = tabBarController.viewControllers?[1] else {
            XCTFail("WalletVC not added as child viewcontroller to tabBarController")
            return
        }
        tabBarController.delegate?.tabBarController?(tabBarController, didSelect: walletVC)
        let iconEvent = IconEvent(textKey: "wallet")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [iconEvent.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["type"], iconEvent.type.rawValue)
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["text"], iconEvent.text)
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level2"] as? String, "login")
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level3"] as? String, "undefined")
    }
    
    func test_didSelect_tabBarItem_profile() throws {
        sut.start()
        guard let profileVC = tabBarController.viewControllers?[2] else {
            XCTFail("ProfileVC not added as child viewcontroller to tabBarController")
            return
        }
        tabBarController.delegate?.tabBarController?(tabBarController, didSelect: profileVC)
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
                                                networkMonitor: MockNetworkMonitor(),
                                                userStore: mockUserStore,
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
                                                networkMonitor: MockNetworkMonitor(),
                                                userStore: mockUserStore,
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
                                                    urlOpener: mockURLOpener,
                                                    userStore: mockUserStore)
        // WHEN the MainCoordinator didRegainFocus from ProfileCoordinator (on user sign out)
        sut.didRegainFocus(fromChild: profileCoordinator)
        // Then the LoginCoordinator should be launched
        XCTAssertEqual(sut.childCoordinators.count, 1)
        XCTAssertTrue(sut.childCoordinators[0] is LoginCoordinator)
    }
}
