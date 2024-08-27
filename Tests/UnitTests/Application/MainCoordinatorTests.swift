import GDSAnalytics
import GDSCommon
@testable import OneLogin
import SecureStore
import XCTest

final class MainCoordinatorTests: XCTestCase {
    var mockWindowManager: MockWindowManager!
    var tabBarController: UITabBarController!
    var mockAnalyticsService: MockAnalyticsService!
    var mockAnalyticsPreferenceStore: MockAnalyticsPreferenceStore!
    var mockAnalyticsCenter: MockAnalyticsCenter!
    var mockSessionManager: MockSessionManager!
    var mockUpdateService: MockAppInformationService!
    var sut: MainCoordinator!
    
    @MainActor
    override func setUp() {
        super.setUp()
        
        mockWindowManager = MockWindowManager(appWindow: UIWindow())
        tabBarController = .init()
        mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsPreferenceStore = MockAnalyticsPreferenceStore()
        mockAnalyticsCenter = MockAnalyticsCenter(analyticsService: mockAnalyticsService,
                                                  analyticsPreferenceStore: mockAnalyticsPreferenceStore)
        mockSessionManager = MockSessionManager()
        mockUpdateService = MockAppInformationService()
        mockWindowManager.appWindow.rootViewController = tabBarController
        mockWindowManager.appWindow.makeKeyAndVisible()
        sut = MainCoordinator(windowManager: mockWindowManager,
                              root: tabBarController,
                              analyticsCenter: mockAnalyticsCenter,
                              sessionManager: mockSessionManager,
                              updateService: mockUpdateService)
    }
    
    override func tearDown() {
        mockWindowManager = nil
        tabBarController = nil
        mockAnalyticsService = nil
        mockAnalyticsPreferenceStore = nil
        mockAnalyticsCenter = nil
        mockSessionManager = nil
        sut = nil
        
        super.tearDown()
    }
}

extension MainCoordinatorTests {
    @MainActor
    func test_checkAppVersion_succeeds() {
        sut.checkAppVersion()
        waitForTruth(self.mockUpdateService.didCallFetchAppInfo, timeout: 20)
    }
    
    @MainActor
    func test_checkAppVersion_throwsError() {
        mockUpdateService.shouldReturnError = true
        sut.checkAppVersion()
        waitForTruth(self.mockUpdateService.didCallFetchAppInfo, timeout: 20)
        
        XCTAssertTrue(sut.root.presentedViewController is GDSErrorViewController)
    }
    
    @MainActor
    func test_start_performsSetUp() {
        // WHEN the MainCoordinator is started
        sut.start()
        // THEN the MainCoordinator should have child coordinators
        XCTAssertEqual(sut.childCoordinators.count, 4)
        XCTAssertTrue(sut.childCoordinators[0] is HomeCoordinator)
        XCTAssertTrue(sut.childCoordinators[1] is WalletCoordinator)
        XCTAssertTrue(sut.childCoordinators[2] is ProfileCoordinator)
        XCTAssertTrue(sut.childCoordinators[3] is LoginCoordinator)
        // THEN the root's delegate is the MainCoordinator
        XCTAssertTrue(sut.root.delegate === sut)
    }
    
    @MainActor
    func test_evaluateRevisit_requiresNewUserToLogin() throws {
        // GIVEN the app has token information stored and the accessToken is valid
        try mockSessionManager.setupSession(returningUser: false, expired: true)
        // WHEN the MainCoordinator's evaluateRevisit method is called
        sut.evaluateRevisit()
        // THEN the session manager should end the current session
        XCTAssertTrue(mockSessionManager.didCallEndCurrentSession)
        XCTAssertTrue(sut.childCoordinators.last is LoginCoordinator)
    }
    
    @MainActor
    func test_evaluateRevisit_requiresExpiredUserToLogin() throws {
        // GIVEN the app has token information stored but the accessToken is expired
        try mockSessionManager.setupSession(expired: true)
        // WHEN the MainCoordinator's evaluateRevisit method is called
        sut.evaluateRevisit()
        // THEN the session manager should end the current session
        XCTAssertTrue(mockSessionManager.didCallEndCurrentSession)
        XCTAssertTrue(sut.childCoordinators.last is LoginCoordinator)
    }
    
    @MainActor
    func test_evaluateRevisit_showsHomeScreenForExistingSession() throws {
        // GIVEN the app has token information store and the accessToken is valid
        try mockSessionManager.setupSession(returningUser: true)
        // WHEN the MainCoordinator's evaluateRevisit method is called
        sut.evaluateRevisit()
        // THEN the session manager should resume the current session
        XCTAssertTrue(mockSessionManager.didCallResumeSession)
        XCTAssertFalse(sut.childCoordinators.last is LoginCoordinator)
    }
    
    @MainActor
    func test_evaluateRevisit_extractIdTokenPayload_JWTVerifierError() throws {
        // GIVEN the app has token information store and the accessToken is valid
        try mockSessionManager.setupSession(returningUser: true)
        // GIVEN the token verifier throws an invalidJWTFormat error
        mockSessionManager.errorFromResumeSession = JWTVerifierError.invalidJWTFormat
        // WHEN the MainCoordinator's evaluateRevisit method is called
        sut.evaluateRevisit()
        // THEN the session manager should end the current session
        XCTAssertTrue(mockSessionManager.didCallEndCurrentSession)
        // THEN the login coordinator should contain that error
        let loginCoordinator = try XCTUnwrap(sut.childCoordinators.first as? LoginCoordinator)
        let loginCoordinatorError = try XCTUnwrap(loginCoordinator.loginError as? JWTVerifierError)
        XCTAssertTrue(loginCoordinatorError == .invalidJWTFormat)
    }
    
    @MainActor
    func test_evaluateRevisit_readFromSecureStore_SecureStoreError_unableToRetrieveFromUserDefaults() throws {
        // GIVEN the app has token information store and the accessToken is valid
        try mockSessionManager.setupSession(returningUser: true)
        // GIVEN the secure store throws an unableToRetrieveFromUserDefaults error
        mockSessionManager.errorFromResumeSession = SecureStoreError.unableToRetrieveFromUserDefaults
        // WHEN the MainCoordinator's evaluateRevisit method is called
        sut.evaluateRevisit()
        // THEN the session manager should end the current session
        XCTAssertTrue(mockSessionManager.didCallEndCurrentSession)
        // THEN the login coordinator should contain that error
        let loginCoordinator = try XCTUnwrap(sut.childCoordinators.first as? LoginCoordinator)
        let loginCoordinatorError = try XCTUnwrap(loginCoordinator.loginError as? SecureStoreError)
        XCTAssertTrue(loginCoordinatorError == .unableToRetrieveFromUserDefaults)
    }
    
    @MainActor
    func test_evaluateRevisit_readFromSecureStore_SecureStoreError_cantInitialiseData() throws {
        // GIVEN the app has token information store and the accessToken is valid
        try mockSessionManager.setupSession(returningUser: true)
        // GIVEN the secure store throws an cantInitialiseData error
        mockSessionManager.errorFromResumeSession = SecureStoreError.cantInitialiseData
        // WHEN the MainCoordinator's evaluateRevisit method is called
        sut.evaluateRevisit()
        // THEN the session manager should end the current session
        XCTAssertTrue(mockSessionManager.didCallEndCurrentSession)
        // THEN the login coordinator should contain that error
        let loginCoordinator = try XCTUnwrap(sut.childCoordinators.first as? LoginCoordinator)
        let loginCoordinatorError = try XCTUnwrap(loginCoordinator.loginError as? SecureStoreError)
        XCTAssertTrue(loginCoordinatorError == .cantInitialiseData)
    }
    
    @MainActor
    func test_evaluateRevisit_readFromSecureStore_SecureStoreError_cantRetrieveKey() throws {
        // GIVEN the app has token information store and the accessToken is valid
        try mockSessionManager.setupSession(returningUser: true)
        // GIVEN the secure store throws an cantRetrieveKey error
        mockSessionManager.errorFromResumeSession = SecureStoreError.cantRetrieveKey
        // WHEN the MainCoordinator's evaluateRevisit method is called
        sut.evaluateRevisit()
        // THEN the session manager should end the current session
        XCTAssertTrue(mockSessionManager.didCallEndCurrentSession)
        // THEN the login coordinator should contain that error
        let loginCoordinator = try XCTUnwrap(sut.childCoordinators.first as? LoginCoordinator)
        let loginCoordinatorError = try XCTUnwrap(loginCoordinator.loginError as? SecureStoreError)
        XCTAssertTrue(loginCoordinatorError == .cantRetrieveKey)
    }
    
    @MainActor
    func test_evaluateRevisit_readFromSecureStore_SecureStoreError_cantDecryptData() throws {
        // GIVEN the app has token information store and the accessToken is valid
        try mockSessionManager.setupSession(returningUser: true)
        // GIVEN the secure store throws an cantDecryptData error
        mockSessionManager.errorFromResumeSession = SecureStoreError.cantDecryptData
        // WHEN the MainCoordinator's evaluateRevisit method is called
        sut.evaluateRevisit()
        // THEN the session manager should not end the current session
        XCTAssertFalse(mockSessionManager.didCallEndCurrentSession)
        // THEN no coordinator should be launched
        XCTAssertEqual(sut.childCoordinators.count, 0)
    }
    
    @MainActor
    func test_startReauth() throws {
        // GIVEN the app has token information store and the accessToken is valid
        try mockSessionManager.setupSession(returningUser: true)
        // WHEN the MainCoordinator is started
        sut.start()
        // WHEN the MainCoordinator receives a start reauth notification
        NotificationCenter.default
            .post(name: Notification.Name(.startReauth), object: nil)
        // THEN the tokens should be deleted; the app should be reset
        XCTAssertTrue(mockSessionManager.didCallEndCurrentSession)
    }
    
    @MainActor
    func test_handleUniversalLink_login() {
        // WHEN the handleUniversalLink method is called
        // This test is purely to get test coverage atm as we will not be able to test for effects on unmocked subcoordinators
        sut.handleUniversalLink(URL(string: "google.co.uk/wallet/123456789")!)
        sut.handleUniversalLink(URL(string: "google.co.uk/redirect/123456789")!)
        sut.handleUniversalLink(URL(string: "google.co.uk/redirect/123456789")!)
    }
    
    @MainActor
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
    
    @MainActor
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
    
    @MainActor
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
    
    @MainActor
    func test_didRegainFocus_fromLoginCoordinator_withBearerToken() throws {
        // GIVEN the user has an active session
        let loginCoordinator = LoginCoordinator(appWindow: mockWindowManager.appWindow,
                                                root: UINavigationController(),
                                                analyticsCenter: mockAnalyticsCenter,
                                                sessionManager: mockSessionManager,
                                                networkMonitor: MockNetworkMonitor(),
                                                loginError: nil)
        // WHEN the MainCoordinator didRegainFocus from the LoginCoordinator
        sut.didRegainFocus(fromChild: loginCoordinator)
        // THEN no coordinator should be launched
        XCTAssertEqual(sut.childCoordinators.count, 0)
    }
    
    @MainActor
    func test_performChildCleanup_fromProfileCoordinator_succeeds() throws {
        // GIVEN the app has token information stored, the user has accepted analytics and the accessToken is valid
        mockAnalyticsPreferenceStore.hasAcceptedAnalytics = true
        try mockSessionManager.setupSession(returningUser: true)
        let profileCoordinator = ProfileCoordinator(analyticsService: mockAnalyticsService,
                                                    urlOpener: MockURLOpener())
        // WHEN the MainCoordinator's performChildCleanup method is called from ProfileCoordinator (on user sign out)
        sut.performChildCleanup(child: profileCoordinator)
        // THEN the tokens should be deleted and the analytics should be reset; the app should be reset
        XCTAssertTrue(mockSessionManager.didCallClearAllSessionData)
        XCTAssertTrue(mockAnalyticsPreferenceStore.hasAcceptedAnalytics == nil)
    }
    
    @MainActor
    func test_performChildCleanup_fromProfileCoordinator_errors() throws {
        UserDefaults.standard.set(true, forKey: FeatureFlags.enableSignoutError.rawValue)
        // GIVEN the app has token information store, the user has accepted analytics and the accessToken is valid
        mockAnalyticsPreferenceStore.hasAcceptedAnalytics = true
        try mockSessionManager.setupSession(returningUser: true)
        let profileCoordinator = ProfileCoordinator(analyticsService: mockAnalyticsService,
                                                    urlOpener: MockURLOpener())
        // WHEN the MainCoordinator's performChildCleanup method is called from ProfileCoordinator (on user sign out)
        // but there was an error in signing out
        sut.performChildCleanup(child: profileCoordinator)
        // THEN the sign out error screen should be presented
        let errroVC = try XCTUnwrap(sut.root.presentedViewController as? GDSErrorViewController)
        XCTAssertTrue(errroVC.viewModel is SignOutErrorViewModel)
        // THEN the tokens shouldn't be deleted and the analytics shouldn't be reset; the app shouldn't be reset
        XCTAssertFalse(mockSessionManager.didCallEndCurrentSession)
        XCTAssertTrue(mockAnalyticsPreferenceStore.hasAcceptedAnalytics == true)
        UserDefaults.standard.set(false, forKey: FeatureFlags.enableSignoutError.rawValue)
    }
}
