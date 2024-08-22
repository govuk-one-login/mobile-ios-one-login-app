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
    var idToken: String!
    var sut: MainCoordinator!
    
    override func setUp() {
        super.setUp()
        
        TokenHolder.shared.clearTokenHolder()
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
        mockTokenVerifier = MockTokenVerifier()
        mockWindowManager.appWindow.rootViewController = tabBarController
        mockWindowManager.appWindow.makeKeyAndVisible()
        sut = MainCoordinator(windowManager: mockWindowManager,
                              root: tabBarController,
                              analyticsCenter: mockAnalyticsCenter,
                              userStore: mockUserStore,
                              tokenVerifier: mockTokenVerifier)
    }
    
    override func tearDown() {
        TokenHolder.shared.clearTokenHolder()
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
        idToken = nil
        sut = nil
        
        super.tearDown()
    }
    
    func returningAuthenticatedUser(expired: Bool = false) throws {
        TokenHolder.shared.tokenResponse = try MockTokenResponse().getJSONData(outdated: expired)
        TokenHolder.shared.idTokenPayload = try MockTokenVerifier().extractPayload("test")
        try mockUserStore.saveItem(TokenHolder.shared.accessToken,
                                   itemName: .accessToken,
                                   storage: .authenticated)
        try mockUserStore.saveItem(TokenHolder.shared.tokenResponse?.idToken,
                                   itemName: .idToken,
                                   storage: .authenticated)
        mockDefaultStore.set(TokenHolder.shared.tokenResponse?.expiryDate, forKey: .accessTokenExpiry)
        idToken = try mockUserStore.readItem(itemName: .idToken,
                                             storage: .authenticated)
    }
    
    func appNotReset() throws {
        XCTAssertNotNil(TokenHolder.shared.accessToken)
        XCTAssertNotNil(TokenHolder.shared.idTokenPayload)
        XCTAssertNotNil(try mockUserStore.readItem(itemName: .accessToken, storage: .authenticated))
        XCTAssertNotNil(try mockUserStore.readItem(itemName: .idToken, storage: .authenticated))
        XCTAssertNotNil(mockUserStore.defaultsStore.value(forKey: .accessTokenExpiry))
        XCTAssertFalse(mockSecureStore.didCallDeleteStore)
    }
    
    func appReset(accessExpiryDeleted: Bool = false) throws {
        XCTAssertNil(TokenHolder.shared.accessToken)
        XCTAssertNil(TokenHolder.shared.idTokenPayload)
        XCTAssertThrowsError(try mockUserStore.readItem(itemName: .accessToken, storage: .authenticated))
        XCTAssertThrowsError(try mockUserStore.readItem(itemName: .idToken, storage: .authenticated))
        if accessExpiryDeleted {
            XCTAssertNil(mockDefaultStore.value(forKey: .accessTokenExpiry))
        }
        XCTAssertTrue(mockSecureStore.didCallDeleteStore)
        XCTAssertTrue(mockWindowManager.hideUnlockWindowCalled)
        XCTAssertTrue(sut.childCoordinators.last is LoginCoordinator)
    }
}

extension MainCoordinatorTests {
    func test_start_performsSetUp() {
        // WHEN the MainCoordinator is started
        sut.start()
        // THEN the MainCoordinator should have child coordinators
        XCTAssertEqual(sut.childCoordinators.count, 1)
        XCTAssertTrue(sut.childCoordinators[0] is QualifyingCoordinator)
        // THEN the root's delegate is the MainCoordinator
        XCTAssertTrue(sut.root.delegate === sut)
    }
    
    func test_evaluateRevisit_newUser() throws {
        // GIVEN the app has token information stored and the accessToken is valid
        mockDefaultStore.set(nil, forKey: .accessTokenExpiry)
        // WHEN the MainCoordinator's evaluateRevisit method is called
//        sut.evaluateRevisit()
        // THEN the tokens should be deleted; the app should be reset
        try appReset(accessExpiryDeleted: true)
    }
    
    func test_evaluateRevisit_notAuthenticatedUser() throws {
        // GIVEN the app has token information stored but the accessToken is expired
        try returningAuthenticatedUser(expired: true)
        // WHEN the MainCoordinator's evaluateRevisit method is called
        sut.evaluateRevisit(idToken: idToken)
        // THEN the access and id tokens should be deleted; the app should require reauth
        XCTAssertThrowsError(try mockSecureStore.readItem(itemName: .accessToken))
        XCTAssertThrowsError(try mockSecureStore.readItem(itemName: .idToken))
        XCTAssertNotNil(mockDefaultStore.value(forKey: .accessTokenExpiry))
    }
    
    func test_evaluateRevisit_returningAuthenticatedUser() throws {
        // GIVEN the app has token information store and the accessToken is valid
        try returningAuthenticatedUser()
        // WHEN the MainCoordinator's evaluateRevisit method is called
//        sut.evaluateRevisit()
        // THEN the is token should be stored in the token holder
        waitForTruth(self.mockWindowManager.hideUnlockWindowCalled, timeout: 20)
        XCTAssertNotNil(TokenHolder.shared.idTokenPayload)
        XCTAssertEqual(TokenHolder.shared.idTokenPayload?.email, "mock@email.com")
    }
    
    func test_evaluateRevisit_extractIdTokenPayload_JWTVerifierError() throws {
        // GIVEN the app has token information store and the accessToken is valid
        try returningAuthenticatedUser()
        // GIVEN the token verifier throws an invalidJWTFormat error
        mockTokenVerifier.extractionError = JWTVerifierError.invalidJWTFormat
        // WHEN the MainCoordinator's evaluateRevisit method is called
//        sut.evaluateRevisit()
        // THEN the tokens should be deleted; the app should be reset
        waitForTruth(self.mockWindowManager.hideUnlockWindowCalled, timeout: 20)
        try appReset()
        // THEN the login coordinator should contain that error
        let loginCoordinator = try XCTUnwrap(sut.childCoordinators.first as? LoginCoordinator)
        let loginCoordinatorError = try XCTUnwrap(loginCoordinator.loginError as? JWTVerifierError)
        XCTAssertTrue(loginCoordinatorError == .invalidJWTFormat)
    }
    
    func test_evaluateRevisit_readFromSecureStore_SecureStoreError_unableToRetrieveFromUserDefaults() throws {
        // GIVEN the app has token information store and the accessToken is valid
        try returningAuthenticatedUser()
        // GIVEN the secure store throws an unableToRetrieveFromUserDefaults error
        mockSecureStore.errorFromReadItem = SecureStoreError.unableToRetrieveFromUserDefaults
        // WHEN the MainCoordinator's evaluateRevisit method is called
//        sut.evaluateRevisit()
        // THEN the tokens should be deleted; the app should be reset
        waitForTruth(self.mockWindowManager.hideUnlockWindowCalled, timeout: 20)
        try appReset()
        // THEN the login coordinator should contain that error
        let loginCoordinator = try XCTUnwrap(sut.childCoordinators.first as? LoginCoordinator)
        let loginCoordinatorError = try XCTUnwrap(loginCoordinator.loginError as? SecureStoreError)
        XCTAssertTrue(loginCoordinatorError == .unableToRetrieveFromUserDefaults)
    }
    
    func test_evaluateRevisit_readFromSecureStore_SecureStoreError_cantInitialiseData() throws {
        // GIVEN the app has token information store and the accessToken is valid
        try returningAuthenticatedUser()
        // GIVEN the secure store throws an cantInitialiseData error
        mockSecureStore.errorFromReadItem = SecureStoreError.cantInitialiseData
        // WHEN the MainCoordinator's evaluateRevisit method is called
//        sut.evaluateRevisit()
        // THEN the tokens should be deleted; the app should be reset
        waitForTruth(self.mockWindowManager.hideUnlockWindowCalled, timeout: 20)
        try appReset()
        // THEN the login coordinator should contain that error
        let loginCoordinator = try XCTUnwrap(sut.childCoordinators.first as? LoginCoordinator)
        let loginCoordinatorError = try XCTUnwrap(loginCoordinator.loginError as? SecureStoreError)
        XCTAssertTrue(loginCoordinatorError == .cantInitialiseData)
    }
    
    func test_evaluateRevisit_readFromSecureStore_SecureStoreError_cantRetrieveKey() throws {
        // GIVEN the app has token information store and the accessToken is valid
        try returningAuthenticatedUser()
        // GIVEN the secure store throws an cantRetrieveKey error
        mockSecureStore.errorFromReadItem = SecureStoreError.cantRetrieveKey
        // WHEN the MainCoordinator's evaluateRevisit method is called
//        sut.evaluateRevisit()
        // THEN the tokens should be deleted; the app should be reset
        waitForTruth(self.mockWindowManager.hideUnlockWindowCalled, timeout: 20)
        try appReset()
        // THEN the login coordinator should contain that error
        let loginCoordinator = try XCTUnwrap(sut.childCoordinators.first as? LoginCoordinator)
        let loginCoordinatorError = try XCTUnwrap(loginCoordinator.loginError as? SecureStoreError)
        XCTAssertTrue(loginCoordinatorError == .cantRetrieveKey)
    }
    
    func test_evaluateRevisit_readFromSecureStore_SecureStoreError_cantDecryptData() throws {
        // GIVEN the app has token information store and the accessToken is valid
        try returningAuthenticatedUser()
        // GIVEN the secure store throws an cantDecryptData error
        mockSecureStore.errorFromReadItem = SecureStoreError.cantDecryptData
        // WHEN the MainCoordinator's evaluateRevisit method is called
//        sut.evaluateRevisit()
        // THEN the tokens should not be deleted; the app should not be reset
        mockSecureStore.errorFromReadItem = nil
        try appNotReset()
        // THEN no coordinator should be launched
        XCTAssertEqual(sut.childCoordinators.count, 0)
    }
    
    func test_startReauth() throws {
        // GIVEN the app has token information store and the accessToken is valid
        try returningAuthenticatedUser()
        // WHEN the MainCoordinator is started
        sut.start()
        // WHEN the MainCoordinator receives a start reauth notification
        NotificationCenter.default
            .post(name: Notification.Name(.startReauth), object: nil)
        // THEN the tokens should be deleted; the app should be reset
        XCTAssertThrowsError(try mockSecureStore.readItem(itemName: .accessToken))
        XCTAssertThrowsError(try mockSecureStore.readItem(itemName: .idToken))
        XCTAssertNotNil(mockDefaultStore.value(forKey: .accessTokenExpiry))
    }
    
    func test_handleUniversalLink_login() {
        // WHEN the handleUniversalLink method is called
        // This test is purely to get test coverage atm as we will not be able to test for effects on unmocked subcoordinators
        sut.handleUniversalLink(URL(string: "google.co.uk/wallet/123456789")!)
        sut.handleUniversalLink(URL(string: "google.co.uk/redirect/123456789")!)
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
        try? returningAuthenticatedUser()
        let qualifyingCoordinator = QualifyingCoordinator(userStore: mockUserStore,
                                                          analyticsCenter: mockAnalyticsCenter)
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
        // GIVEN the access token has been stored in the token holder
        TokenHolder.shared.accessToken = "testAccessToken"
        let loginCoordinator = LoginCoordinator(appWindow: mockWindowManager.appWindow,
                                                root: UINavigationController(),
                                                analyticsCenter: mockAnalyticsCenter,
                                                userStore: mockUserStore,
                                                networkMonitor: MockNetworkMonitor(),
                                                loginError: nil)
        // WHEN the MainCoordinator didRegainFocus from the LoginCoordinator
        sut.didRegainFocus(fromChild: loginCoordinator)
        // THEN no coordinator should be launched
        XCTAssertEqual(sut.childCoordinators.count, 0)
    }
    
    func test_didRegainFocus_fromLoginCoordinator_withoutBearerToken() throws {
        // GIVEN the token holder does not contain tokens
        TokenHolder.shared.clearTokenHolder()
        let loginCoordinator = LoginCoordinator(appWindow: mockWindowManager.appWindow,
                                                root: UINavigationController(),
                                                analyticsCenter: mockAnalyticsCenter,
                                                userStore: mockUserStore,
                                                networkMonitor: MockNetworkMonitor(),
                                                loginError: nil)
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

    func test_didRegainFocus_fromQualifyingCoordinator_withoutIdToken() throws {
        TokenHolder.shared.clearTokenHolder()
        let qualifyingCoordinator = QualifyingCoordinator(userStore: mockUserStore,
                                                          analyticsCenter: mockAnalyticsCenter)
        // WHEN the MainCoordinator regains focus from the QualifyingCoordinator with no idToken
        sut.didRegainFocus(fromChild: qualifyingCoordinator)
        // THEN the full login journey should be triggered
        XCTAssertEqual(sut.childCoordinators.count, 1)
        // THEN the child should be LoginCoordinator
        XCTAssertTrue(sut.childCoordinators.first is LoginCoordinator)
    }

    func test_didRegainFocus_fromQualifyingCoordinator_withIdToken() throws {
        try returningAuthenticatedUser()
        let idToken = try mockSecureStore.readItem(itemName: .idToken)
        let qualifyingCoordinator = QualifyingCoordinator(userStore: mockUserStore,
                                                          analyticsCenter: mockAnalyticsCenter)
//        qualifyingCoordinator.idToken = idToken
        // WHEN the MainCoordinator regains focus from the QualifyingCoordinator with an idToken
        sut.didRegainFocus(fromChild: qualifyingCoordinator)
        // THEN the idToken should be saved in the TokenHolder
        XCTAssertNotNil(idToken)
        XCTAssertEqual(sut.childCoordinators.count, 1)
        XCTAssertTrue(sut.childCoordinators.first is LoginCoordinator)

    }

    func test_performChildCleanup_fromProfileCoordinator_succeeds() throws {
        // GIVEN the app has token information stored, the user has accepted analytics and the accessToken is valid
        mockAnalyticsPreferenceStore.hasAcceptedAnalytics = true
        try returningAuthenticatedUser()
        let profileCoordinator = ProfileCoordinator(analyticsService: mockAnalyticsService,
                                                    urlOpener: MockURLOpener())
        // WHEN the MainCoordinator's performChildCleanup method is called from ProfileCoordinator (on user sign out)
        sut.performChildCleanup(child: profileCoordinator)
        // THEN the tokens should be deleted and the analytics should be reset; the app should be reset
        XCTAssertTrue(mockAnalyticsPreferenceStore.hasAcceptedAnalytics == nil)
        try appReset(accessExpiryDeleted: true)
    }
    
    func test_performChildCleanup_fromProfileCoordinator_errors() throws {
        UserDefaults.standard.set(true, forKey: FeatureFlags.enableSignoutError.rawValue)
        // GIVEN the app has token information store, the user has accepted analytics and the accessToken is valid
        mockAnalyticsPreferenceStore.hasAcceptedAnalytics = true
        try returningAuthenticatedUser()
        let profileCoordinator = ProfileCoordinator(analyticsService: mockAnalyticsService,
                                                    urlOpener: MockURLOpener())
        // WHEN the MainCoordinator's performChildCleanup method is called from ProfileCoordinator (on user sign out)
        // but there was an error in signing out
        sut.performChildCleanup(child: profileCoordinator)
        // THEN the sign out error screen should be presented
        let errroVC = try XCTUnwrap(sut.root.presentedViewController as? GDSErrorViewController)
        XCTAssertTrue(errroVC.viewModel is SignOutErrorViewModel)
        // THEN the tokens shouldn't be deleted and the analytics shouldn't be reset; the app shouldn't be reset
        XCTAssertTrue(mockAnalyticsPreferenceStore.hasAcceptedAnalytics == true)
        try appNotReset()
        UserDefaults.standard.set(false, forKey: FeatureFlags.enableSignoutError.rawValue)
    }
    
    func test_performChildCleanup_fromHomeCoordinator() throws {
        let homeCoordinator = HomeCoordinator(analyticsService: mockAnalyticsService,
                                              userStore: mockUserStore)
        // WHEN the MainCoordinator's performChildCleanup method is called from HomeCoordinator (on user reauth)
        sut.performChildCleanup(child: homeCoordinator)
    }
}
