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
    var mockOpenSecureStore: MockSecureStoreService!
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
        mockOpenSecureStore = MockSecureStoreService()
        mockDefaultStore = MockDefaultsStore()
        mockUserStore = UserStorage(authenticatedStore: mockSecureStore,
                                    openStore: mockOpenSecureStore,
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
        mockOpenSecureStore = nil
        mockDefaultStore = nil
        mockUserStore = nil
        mockTokenVerifier = nil
        mockURLOpener = nil
        sut = nil
        
        super.tearDown()
    }
    
    func returningAuthenticatedUser(expired: Bool = false) throws {
        let accessToken = try MockTokenResponse().getJSONData().accessToken
        TokenHolder.shared.accessToken = accessToken
        TokenHolder.shared.idTokenPayload = try MockTokenVerifier().extractPayload("test")
        try mockUserStore.saveItem(accessToken,
                                   itemName: .accessToken,
                                   storage: .authenticated)
        try mockUserStore.saveItem(MockTokenResponse().getJSONData().idToken,
                                   itemName: .idToken,
                                   storage: .authenticated)
        let date: Date
        if expired {
            date = Date() - 60
        } else {
            date = Date() + 60
        }
        mockDefaultStore.set(date, forKey: .accessTokenExpiry)
    }
    
    func appNotReset() throws {
        XCTAssertNotNil(TokenHolder.shared.accessToken)
        XCTAssertNotNil(TokenHolder.shared.idTokenPayload)
        XCTAssertNotNil(try mockSecureStore.readItem(itemName: .accessToken))
        XCTAssertNotNil(try mockSecureStore.readItem(itemName: .idToken))
        XCTAssertNotNil(mockDefaultStore.value(forKey: .accessTokenExpiry))
        XCTAssertFalse(mockSecureStore.didCallDeleteStore)
    }
    
    func appReset() throws {
        XCTAssertNil(TokenHolder.shared.accessToken)
        XCTAssertNil(TokenHolder.shared.idTokenPayload)
        XCTAssertThrowsError(try mockSecureStore.readItem(itemName: .accessToken))
        XCTAssertThrowsError(try mockSecureStore.readItem(itemName: .idToken))
        XCTAssertNil(mockDefaultStore.value(forKey: .accessTokenExpiry))
        XCTAssertTrue(mockSecureStore.didCallDeleteStore)
        XCTAssertTrue(mockWindowManager.hideUnlockWindowCalled)
        XCTAssertTrue(sut.childCoordinators.last is LoginCoordinator)
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
        // GIVEN the app has token information store and the accessToken is valid
        try returningAuthenticatedUser()
        // WHEN the MainCoordinator's start method is called
        sut.start()
        // THEN the tokens should not be deleted; the app should not be reset
        waitForTruth(self.mockWindowManager.hideUnlockWindowCalled, timeout: 20)
        try appNotReset()
    }
    
    func test_start_notAuthenticatedUser() throws {
        // GIVEN the app has token information store and the accessToken is valid
        try returningAuthenticatedUser(expired: true)
        // WHEN the MainCoordinator's start method is called
        sut.start()
        // THEN the tokens should be deleted; the app should be reset
        try appReset()
    }
    
    func test_evaluateRevisit_returningAuthenticatedUser() throws {
        // GIVEN the app has token information store and the accessToken is valid
        try returningAuthenticatedUser()
        // WHEN the MainCoordinator's evaluateRevisit method is called
        sut.evaluateRevisit()
        // THEN the tokens should not be deleted; the app should not be reset
        waitForTruth(self.mockWindowManager.hideUnlockWindowCalled, timeout: 20)
        try appNotReset()
    }
    
    func test_evaluateRevisit_notAuthenticatedUser() throws {
        // GIVEN the app has token information store but the accessToken is expired
        try returningAuthenticatedUser(expired: true)
        // WHEN the MainCoordinator's evaluateRevisit method is called
        sut.evaluateRevisit()
        // THEN the tokens should be deleted; the app should be reset
        try appReset()
    }
    
    func test_evaluateRevisit_extractIdTokenPayload_JWTVerifierError() throws {
        // GIVEN the app has token information store and the accessToken is valid
        try returningAuthenticatedUser()
        // GIVEN the token verifier throws an invalidJWTFormat error
        mockTokenVerifier.extractionError = JWTVerifierError.invalidJWTFormat
        // WHEN the MainCoordinator's evaluateRevisit method is called
        sut.evaluateRevisit()
        // THEN the tokens should be deleted; the app should be reset
        waitForTruth(self.mockWindowManager.hideUnlockWindowCalled, timeout: 20)
        try appReset()
        // THEN the login coordinator should contain that error
        let loginCoordinator = try XCTUnwrap(sut.childCoordinators.first as? LoginCoordinator)
        let loginCoordinatorError = try XCTUnwrap(loginCoordinator.loginError as? JWTVerifierError)
        XCTAssertTrue(loginCoordinatorError == .invalidJWTFormat)
    }
    
    func test_evaluateRevisit_extractIdTokenPayload_SecureStoreError_unableToRetrieveFromUserDefaults() throws {
        // GIVEN the app has token information store and the accessToken is valid
        try returningAuthenticatedUser()
        // GIVEN the token verifier throws an unableToRetrieveFromUserDefaults error
        mockTokenVerifier.extractionError = SecureStoreError.unableToRetrieveFromUserDefaults
        // WHEN the MainCoordinator's evaluateRevisit method is called
        sut.evaluateRevisit()
        // THEN the tokens should be deleted; the app should be reset
        waitForTruth(self.mockWindowManager.hideUnlockWindowCalled, timeout: 20)
        try appReset()
        // THEN the login coordinator should contain that error
        let loginCoordinator = try XCTUnwrap(sut.childCoordinators.first as? LoginCoordinator)
        let loginCoordinatorError = try XCTUnwrap(loginCoordinator.loginError as? SecureStoreError)
        XCTAssertTrue(loginCoordinatorError == .unableToRetrieveFromUserDefaults)
    }
    
    func test_evaluateRevisit_extractIdTokenPayload_SecureStoreError_cantInitialiseData() throws {
        // GIVEN the app has token information store and the accessToken is valid
        try returningAuthenticatedUser()
        // GIVEN the token verifier throws an cantInitialiseData error
        mockTokenVerifier.extractionError = SecureStoreError.cantInitialiseData
        // WHEN the MainCoordinator's evaluateRevisit method is called
        sut.evaluateRevisit()
        // THEN the tokens should be deleted; the app should be reset
        waitForTruth(self.mockWindowManager.hideUnlockWindowCalled, timeout: 20)
        try appReset()
        // THEN the login coordinator should contain that error
        let loginCoordinator = try XCTUnwrap(sut.childCoordinators.first as? LoginCoordinator)
        let loginCoordinatorError = try XCTUnwrap(loginCoordinator.loginError as? SecureStoreError)
        XCTAssertTrue(loginCoordinatorError == .cantInitialiseData)
    }
    
    func test_evaluateRevisit_extractIdTokenPayload_SecureStoreError_cantRetrieveKey() throws {
        // GIVEN the app has token information store and the accessToken is valid
        try returningAuthenticatedUser()
        // GIVEN the token verifier throws an cantRetrieveKey error
        mockTokenVerifier.extractionError = SecureStoreError.cantRetrieveKey
        // WHEN the MainCoordinator's evaluateRevisit method is called
        sut.evaluateRevisit()
        // THEN the tokens should be deleted; the app should be reset
        waitForTruth(self.mockWindowManager.hideUnlockWindowCalled, timeout: 20)
        try appReset()
        // THEN the login coordinator should contain that error
        let loginCoordinator = try XCTUnwrap(sut.childCoordinators.first as? LoginCoordinator)
        let loginCoordinatorError = try XCTUnwrap(loginCoordinator.loginError as? SecureStoreError)
        XCTAssertTrue(loginCoordinatorError == .cantRetrieveKey)
    }
    
    func test_evaluateRevisit_extractIdTokenPayload_SecureStoreError_cantDecryptData() throws {
        // GIVEN the app has token information store and the accessToken is valid
        try returningAuthenticatedUser()
        // GIVEN the token verifier throws an cantDecryptData error
        mockTokenVerifier.extractionError = SecureStoreError.cantDecryptData
        // WHEN the MainCoordinator's evaluateRevisit method is called
        sut.evaluateRevisit()
        // THEN the tokens should not be deleted; the app should not be reset
        waitForTruth(self.mockWindowManager.hideUnlockWindowCalled == false, timeout: 20)
        try appNotReset()
        // THEN no coordinator should be launched
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
        TokenHolder.shared.accessToken = "testAccessToken"
        let loginCoordinator = LoginCoordinator(windowManager: mockWindowManager,
                                                root: UINavigationController(),
                                                analyticsCenter: mockAnalyticsCenter,
                                                userStore: mockUserStore,
                                                networkMonitor: MockNetworkMonitor())
        // WHEN the MainCoordinator didRegainFocus from the LoginCoordinator
        sut.didRegainFocus(fromChild: loginCoordinator)
        // THEN no coordinator should be launched
        XCTAssertEqual(sut.childCoordinators.count, 0)
    }
    
    func test_didRegainFocus_fromLoginCoordinator_withoutBearerToken() throws {
        TokenHolder.shared.clearTokenHolder()
        let loginCoordinator = LoginCoordinator(windowManager: mockWindowManager,
                                                root: UINavigationController(),
                                                analyticsCenter: mockAnalyticsCenter,
                                                userStore: mockUserStore,
                                                networkMonitor: MockNetworkMonitor())
        // WHEN the MainCoordinator didRegainFocus from the LoginCoordinator
        sut.didRegainFocus(fromChild: loginCoordinator)
        // THEN no coordinator should be launched
        XCTAssertEqual(sut.childCoordinators.count, 0)
        // THEN the token holders bearer token should not have the access token
        do {
            _ = try TokenHolder.shared.bearerToken
            XCTFail("Should throw TokenError error")
        } catch {
            XCTAssertTrue(error is TokenError)
        }
    }
    
    func test_performChildCleanup_fromProfileCoordinator_succeeds() throws {
        // GIVEN the app has token information store, the user has accepted analytics and the accessToken is valid
        mockAnalyticsPreferenceStore.hasAcceptedAnalytics = true
        try returningAuthenticatedUser()
        let profileCoordinator = ProfileCoordinator(analyticsService: mockAnalyticsService,
                                                    userStore: mockUserStore,
                                                    urlOpener: mockURLOpener)
        // WHEN the MainCoordinator's performChildCleanup method is called from ProfileCoordinator (on user sign out)
        sut.performChildCleanup(child: profileCoordinator)
        // THEN the tokens should be deleted and the analytics should be reset; the app should be reset
        XCTAssertTrue(mockAnalyticsPreferenceStore.hasAcceptedAnalytics == nil)
        try appReset()
    }
    
    func test_performChildCleanup_fromProfileCoordinator_errors() throws {
        UserDefaults.standard.set(true, forKey: "EnableSignoutError")
        // GIVEN the app has token information store, the user has accepted analytics and the accessToken is valid
        mockAnalyticsPreferenceStore.hasAcceptedAnalytics = true
        try returningAuthenticatedUser()
        let profileCoordinator = ProfileCoordinator(analyticsService: mockAnalyticsService,
                                                    userStore: mockUserStore,
                                                    urlOpener: mockURLOpener)
        // WHEN the MainCoordinator's performChildCleanup method is called from ProfileCoordinator (on user sign out)
        // but there was an error in signing out
        sut.performChildCleanup(child: profileCoordinator)
        // THEN the sign out error screen should be presented
        let presentedVC = try XCTUnwrap(sut.root.presentedViewController as? UINavigationController)
        XCTAssertTrue(presentedVC.topViewController is GDSErrorViewController)
        let errroVC = try XCTUnwrap(presentedVC.topViewController as? GDSErrorViewController)
        XCTAssertTrue(errroVC.viewModel is SignOutErrorViewModel)
        // THEN the tokens shouldn't be deleted and the analytics shouldn't be reset; the app shouldn't be reset
        XCTAssertTrue(mockAnalyticsPreferenceStore.hasAcceptedAnalytics == true)
        try appNotReset()
        UserDefaults.standard.set(false, forKey: "EnableSignoutError")
    }
}
