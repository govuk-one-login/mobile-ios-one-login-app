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
        
        super.tearDown()
    }
    
    func returningAuthenticatedUser(outdated: Bool = false) throws {
        let accessToken = try MockTokenResponse().getJSONData().accessToken
        sut.tokenHolder.accessToken = accessToken
        sut.tokenHolder.idTokenPayload = try MockTokenVerifier().extractPayload("test")
        try mockSecureStore.saveItem(item: accessToken, itemName: .accessToken)
        try mockSecureStore.saveItem(item: XCTUnwrap(MockTokenResponse().getJSONData().idToken), itemName: .idToken)
        let date: Date
        if outdated {
            date = Date() - 60
        } else {
            date = Date() + 60
        }
        mockDefaultStore.set(date, forKey: .accessTokenExpiry)
    }
}

extension MainCoordinatorTests {
    func test_start_assignsRootDelegate() {
        // WHEN the MainCoordinator is started
        sut.start()
        // THEN the root's delegate is the MainCoordinator
        XCTAssertTrue(sut.root.delegate === sut)
    }
    
    func test_start_launchesSubCoordinators() {
        // WHEN the MainCoordinator is started
        sut.start()
        // THEN the MainCoordinator should have child coordinators
        XCTAssertEqual(sut.childCoordinators.count, 4)
        XCTAssertTrue(sut.childCoordinators[0] is HomeCoordinator)
        XCTAssertTrue(sut.childCoordinators[1] is WalletCoordinator)
        XCTAssertTrue(sut.childCoordinators[2] is ProfileCoordinator)
        XCTAssertTrue(sut.childCoordinators[3] is LoginCoordinator)
    }
    
    func test_start_returningAuthenticatedUser() throws {
        // GIVEN the secure store has a valid idToken saved and defaults store has the access token expiry saved
        try returningAuthenticatedUser()
        // WHEN the MainCoordinator's evaluateRevisit method is called with an action
        sut.start()
        // THEN the payload will be extracted from the idToken and the unlock window will be hidden
        waitForTruth(self.mockWindowManager.hideUnlockWindowCalled, timeout: 20)
        XCTAssertNotNil(sut.tokenHolder.accessToken)
        XCTAssertNotNil(sut.tokenHolder.idTokenPayload)
        XCTAssertNotNil(try mockSecureStore.readItem(itemName: .accessToken))
        XCTAssertNotNil(try mockSecureStore.readItem(itemName: .idToken))
        XCTAssertNotNil(mockDefaultStore.value(forKey: .accessTokenExpiry))
        XCTAssertFalse(mockSecureStore.didCallDeleteStore)
    }
    
    func test_start_notAuthenticatedUser() throws {
        // GIVEN the secure store has a valid idToken saved and defaults store has the access token expiry saved
        try returningAuthenticatedUser(outdated: true)
        // WHEN the MainCoordinator's evaluateRevisit method is called with an action
        sut.start()
        // THEN the payload will be extracted from the idToken and the unlock window will be hidden
        XCTAssertNil(sut.tokenHolder.accessToken)
        XCTAssertNil(sut.tokenHolder.idTokenPayload)
        XCTAssertThrowsError(try mockSecureStore.readItem(itemName: .accessToken))
        XCTAssertThrowsError(try mockSecureStore.readItem(itemName: .idToken))
        XCTAssertNil(mockDefaultStore.value(forKey: .accessTokenExpiry))
        XCTAssertTrue(mockSecureStore.didCallDeleteStore)
        XCTAssertTrue(mockWindowManager.hideUnlockWindowCalled)
        XCTAssertTrue(sut.childCoordinators.last is LoginCoordinator)
    }
    
    func test_evaluateRevisit_returningAuthenticatedUser() throws {
        // GIVEN the secure store has a valid idToken saved and defaults store has the access token expiry saved
        try returningAuthenticatedUser()
        // WHEN the MainCoordinator's evaluateRevisit method is called with an action
        sut.evaluateRevisit()
        // THEN the payload will be extracted from the idToken
        waitForTruth(self.mockWindowManager.hideUnlockWindowCalled, timeout: 20)
        XCTAssertNotNil(sut.tokenHolder.accessToken)
        XCTAssertNotNil(sut.tokenHolder.idTokenPayload)
        XCTAssertNotNil(try mockSecureStore.readItem(itemName: .accessToken))
        XCTAssertNotNil(try mockSecureStore.readItem(itemName: .idToken))
        XCTAssertNotNil(mockDefaultStore.value(forKey: .accessTokenExpiry))
        XCTAssertFalse(mockSecureStore.didCallDeleteStore)
    }
    
    func test_evaluateRevisit_notAuthenticatedUser() throws {
        try returningAuthenticatedUser(outdated: true)
        // WHEN the MainCoordinator's evaluateRevisit method is called with an action
        sut.evaluateRevisit()
        // THEN the payload will be extracted from the idToken and the unlock window will be hidden
        XCTAssertNil(sut.tokenHolder.accessToken)
        XCTAssertNil(sut.tokenHolder.idTokenPayload)
        XCTAssertThrowsError(try mockSecureStore.readItem(itemName: .accessToken))
        XCTAssertThrowsError(try mockSecureStore.readItem(itemName: .idToken))
        XCTAssertNil(mockDefaultStore.value(forKey: .accessTokenExpiry))
        XCTAssertTrue(mockSecureStore.didCallDeleteStore)
        XCTAssertTrue(mockWindowManager.hideUnlockWindowCalled)
        XCTAssertTrue(sut.childCoordinators.first is LoginCoordinator)
    }
    
    func test_evaluateRevisit_extractIdTokenPayload_JWTVerifierError() throws {
        // GIVEN the secure store has a valid idToken saved and defaults store has the access token expiry saved
        try returningAuthenticatedUser()
        mockTokenVerifier.extractionError = JWTVerifierError.invalidJWTFormat
        // WHEN the MainCoordinator's evaluateRevisit method is called with an action, and the extraction fails
        sut.evaluateRevisit()
        // THEN the access token is removed from the token holder, the id token is removed
        // and the access token expiry is cleared
        waitForTruth(self.mockWindowManager.hideUnlockWindowCalled, timeout: 20)
        XCTAssertNil(sut.tokenHolder.accessToken)
        XCTAssertNil(sut.tokenHolder.idTokenPayload)
        XCTAssertThrowsError(try mockSecureStore.readItem(itemName: .accessToken))
        XCTAssertThrowsError(try mockSecureStore.readItem(itemName: .idToken))
        XCTAssertNil(mockDefaultStore.value(forKey: .accessTokenExpiry))
        XCTAssertTrue(mockSecureStore.didCallDeleteStore)
        XCTAssertTrue(sut.childCoordinators.first is LoginCoordinator)
        let loginCoordinator = try XCTUnwrap(sut.childCoordinators.first as? LoginCoordinator)
        let loginCoordinatorError = try XCTUnwrap(loginCoordinator.loginError as? JWTVerifierError)
        XCTAssertTrue(loginCoordinatorError == .invalidJWTFormat)
    }
    
    func test_evaluateRevisit_extractIdTokenPayload_SecureStoreError_unableToRetrieveFromUserDefaults() throws {
        // GIVEN the secure store has a valid idToken saved and defaults store has the access token expiry saved
        try returningAuthenticatedUser()
        mockTokenVerifier.extractionError = SecureStoreError.unableToRetrieveFromUserDefaults
        // WHEN the MainCoordinator's evaluateRevisit method is called with an action, and the extraction fails
        sut.evaluateRevisit()
        // THEN the access token is removed from the token holder, the id token is removed
        // and the access token expiry is cleared
        waitForTruth(self.mockWindowManager.hideUnlockWindowCalled, timeout: 20)
        XCTAssertNil(sut.tokenHolder.accessToken)
        XCTAssertNil(sut.tokenHolder.idTokenPayload)
        XCTAssertThrowsError(try mockSecureStore.readItem(itemName: .accessToken))
        XCTAssertThrowsError(try mockSecureStore.readItem(itemName: .idToken))
        XCTAssertNil(mockDefaultStore.value(forKey: .accessTokenExpiry))
        XCTAssertTrue(mockSecureStore.didCallDeleteStore)
        XCTAssertTrue(sut.childCoordinators.first is LoginCoordinator)
        let loginCoordinator = try XCTUnwrap(sut.childCoordinators.first as? LoginCoordinator)
        let loginCoordinatorError = try XCTUnwrap(loginCoordinator.loginError as? SecureStoreError)
        XCTAssertTrue(loginCoordinatorError == .unableToRetrieveFromUserDefaults)
    }
    
    func test_evaluateRevisit_extractIdTokenPayload_SecureStoreError_cantInitialiseData() throws {
        // GIVEN the secure store has a valid idToken saved and defaults store has the access token expiry saved
        try returningAuthenticatedUser()
        mockTokenVerifier.extractionError = SecureStoreError.cantInitialiseData
        // WHEN the MainCoordinator's evaluateRevisit method is called with an action, and the extraction fails
        sut.evaluateRevisit()
        // THEN the access token is removed from the token holder, the id token is removed
        // and the access token expiry is cleared
        waitForTruth(self.mockWindowManager.hideUnlockWindowCalled, timeout: 20)
        XCTAssertNil(sut.tokenHolder.accessToken)
        XCTAssertNil(sut.tokenHolder.idTokenPayload)
        XCTAssertThrowsError(try mockSecureStore.readItem(itemName: .accessToken))
        XCTAssertThrowsError(try mockSecureStore.readItem(itemName: .idToken))
        XCTAssertNil(mockDefaultStore.value(forKey: .accessTokenExpiry))
        XCTAssertTrue(mockSecureStore.didCallDeleteStore)
        XCTAssertTrue(sut.childCoordinators.first is LoginCoordinator)
        let loginCoordinator = try XCTUnwrap(sut.childCoordinators.first as? LoginCoordinator)
        let loginCoordinatorError = try XCTUnwrap(loginCoordinator.loginError as? SecureStoreError)
        XCTAssertTrue(loginCoordinatorError == .cantInitialiseData)
    }
    
    func test_evaluateRevisit_extractIdTokenPayload_SecureStoreError_cantRetrieveKey() throws {
        // GIVEN the secure store has a valid idToken saved and defaults store has the access token expiry saved
        try returningAuthenticatedUser()
        mockTokenVerifier.extractionError = SecureStoreError.cantRetrieveKey
        // WHEN the MainCoordinator's evaluateRevisit method is called with an action, and the extraction fails
        sut.evaluateRevisit()
        // THEN the access token is removed from the token holder, the id token is removed
        // and the access token expiry is cleared
        waitForTruth(self.mockWindowManager.hideUnlockWindowCalled, timeout: 20)
        XCTAssertNil(sut.tokenHolder.accessToken)
        XCTAssertNil(sut.tokenHolder.idTokenPayload)
        XCTAssertThrowsError(try mockSecureStore.readItem(itemName: .accessToken))
        XCTAssertThrowsError(try mockSecureStore.readItem(itemName: .idToken))
        XCTAssertNil(mockDefaultStore.value(forKey: .accessTokenExpiry))
        XCTAssertTrue(mockSecureStore.didCallDeleteStore)
        XCTAssertTrue(sut.childCoordinators.first is LoginCoordinator)
        let loginCoordinator = try XCTUnwrap(sut.childCoordinators.first as? LoginCoordinator)
        let loginCoordinatorError = try XCTUnwrap(loginCoordinator.loginError as? SecureStoreError)
        XCTAssertTrue(loginCoordinatorError == .cantRetrieveKey)
    }
    
    func test_evaluateRevisit_extractIdTokenPayload_SecureStoreError_cantDecryptData() throws {
        // GIVEN the secure store has a valid idToken saved and defaults store has the access token expiry saved
        try returningAuthenticatedUser()
        mockTokenVerifier.extractionError = SecureStoreError.cantDecryptData
        // WHEN the MainCoordinator's evaluateRevisit method is called with an action, and local auth fails
        // NOTE: cantDecryptData is the error secure store throws when local auth fails
        sut.evaluateRevisit()
        // THEN the idToken will be nil
        waitForTruth(self.mockWindowManager.hideUnlockWindowCalled == false, timeout: 20)
        // THEN the unlock window will not have been dismissed
        XCTAssertNotNil(sut.tokenHolder.accessToken)
        XCTAssertNotNil(sut.tokenHolder.idTokenPayload)
        XCTAssertNotNil(try mockSecureStore.readItem(itemName: .accessToken))
        XCTAssertNotNil(try mockSecureStore.readItem(itemName: .idToken))
        XCTAssertNotNil(mockDefaultStore.value(forKey: .accessTokenExpiry))
        XCTAssertFalse(mockSecureStore.didCallDeleteStore)
        // THEN the LoginCoordinator will NOT be presented
        XCTAssertEqual(sut.childCoordinators.count, 0)
    }
    
    func test_handleUniversalLink_login() {
        // WHEN the handleUniversalLink method is called
        // This test is purely to get test coverage atm as we will not be able to test for effects on unmocked subcoordinators
        sut.handleUniversalLink(URL(string: "google.co.uk/wallet/123456789")!)
        sut.handleUniversalLink(URL(string: "google.co.uk/redirect/123456789")!)
    }
    
    func test_didSelect_tabBarItem_home() {
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
    
    func test_didSelect_tabBarItem_wallet() {
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
    
    func test_didSelect_tabBarItem_profile() {
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
        try returningAuthenticatedUser()
        let profileCoordinator = ProfileCoordinator(analyticsCenter: mockAnalyticsCenter,
                                                    userStore: mockUserStore,
                                                    tokenHolder: TokenHolder(),
                                                    urlOpener: mockURLOpener)
        // WHEN the MainCoordinator didRegainFocus from ProfileCoordinator (on user sign out)
        sut.didRegainFocus(fromChild: profileCoordinator)
        // Then the LoginCoordinator should be launched
        XCTAssertNil(sut.tokenHolder.accessToken)
        XCTAssertNil(sut.tokenHolder.idTokenPayload)
        XCTAssertThrowsError(try mockSecureStore.readItem(itemName: .accessToken))
        XCTAssertThrowsError(try mockSecureStore.readItem(itemName: .idToken))
        XCTAssertNil(mockDefaultStore.value(forKey: .accessTokenExpiry))
        XCTAssertTrue(mockSecureStore.didCallDeleteStore)
        XCTAssertTrue(sut.childCoordinators.first is LoginCoordinator)
    }
    
    func test_performChildCleanup_fromLoginCoordinator() {
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
