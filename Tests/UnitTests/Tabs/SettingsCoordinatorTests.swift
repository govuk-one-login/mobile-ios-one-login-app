import GDSAnalytics
import GDSCommon
import Networking
@testable import OneLogin
import SecureStore
import XCTest

@MainActor
final class SettingsCoordinatorTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var mockSessionManager: MockSessionManager!
    var mockNetworkClient: NetworkClient!
    var urlOpener: URLOpener!
    var sut: SettingsCoordinator!
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        mockSessionManager = MockSessionManager()
        mockNetworkClient = NetworkClient()
        mockNetworkClient.authorizationProvider = MockAuthenticationProvider()
        urlOpener = MockURLOpener()
        sut = SettingsCoordinator(analyticsService: mockAnalyticsService,
                                  sessionManager: mockSessionManager,
                                  networkClient: mockNetworkClient,
                                  urlOpener: urlOpener)
        let window = UIWindow()
        window.rootViewController = sut.root
        window.makeKeyAndVisible()
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        mockSessionManager = nil
        mockNetworkClient = nil
        urlOpener = nil
        sut = nil
        
        WalletAvailabilityService.hasAccessedBefore = false
        
        super.tearDown()
    }
    
    func test_tabBarItem() {
        // WHEN the SettingsCoordinator has started
        sut.start()
        let settingsTab = UITabBarItem(title: "Settings",
                                      image: UIImage(systemName: "gearshape"),
                                      tag: 2)
        // THEN the bar button item of the root is correctly configured
        XCTAssertEqual(sut.root.tabBarItem.title, settingsTab.title)
        XCTAssertEqual(sut.root.tabBarItem.image, settingsTab.image)
        XCTAssertEqual(sut.root.tabBarItem.tag, settingsTab.tag)
    }
    
    func test_didBecomeSelected() {
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        sut.didBecomeSelected()
        let event = IconEvent(textKey: "app_settingsTitle")
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, event.parameters)
    }
    
    func test_openSignOutPage() throws {
        // WHEN the SettingsCoordinator is started
        sut.start()
        // WHEN the openSignOutPage method is called
        sut.openSignOutPage()
        // THEN the presented view controller's view model is the WalletSignOutPageViewModel
        let presentedVC = try XCTUnwrap(sut.root.presentedViewController as? UINavigationController)
        let viewController = try XCTUnwrap(presentedVC.topViewController as? GDSInstructionsViewController)
        XCTAssertTrue(viewController.viewModel is SignOutPageViewModel)
    }
    
    func test_tapSignoutClearsData() async throws {
        let exp = XCTNSNotificationExpectation(
            name: .userDidLogout,
            object: nil,
            notificationCenter: NotificationCenter.default
        )
        // GIVEN the user is on the signout page
        sut.start()
        // WHEN the openSignOutPage method is called
        sut.openSignOutPage()
        let presentedVC = try XCTUnwrap(sut.root.presentedViewController as? UINavigationController)
        // WHEN the button on the screen is hit
        let signOutButton: UIButton = try XCTUnwrap(presentedVC.topViewController?.view[child: "instructions-button"])
        signOutButton.sendActions(for: .touchUpInside)
        // THEN clear all session data is called
        await fulfillment(of: [exp], timeout: 5)
        XCTAssertTrue(mockSessionManager.didCallClearAllSessionData)
    }
    
    func test_tapSignOut_errors() throws {
        // GIVEN an error is returned from clearAllSessionData
        mockSessionManager.errorFromClearAllSessionData = MockWalletError.cantDelete
        // GIVEN the user is on the signout page
        sut.start()
        // WHEN the openSignOutPage method is called
        sut.openSignOutPage()
        let presentedVC = try XCTUnwrap(sut.root.presentedViewController as? UINavigationController)
        // WHEN the user signs out
        let signOutButton: UIButton = try XCTUnwrap(presentedVC.topViewController?.view[child: "instructions-button"])
        signOutButton.sendActions(for: .touchUpInside)
        // THEN the presented sign out error screen is shown
        waitForTruth((self.sut.root.presentedViewController as? GDSErrorScreen)?.viewModel is SignOutErrorViewModel,
                     timeout: 20)
    }
    
    func test_showDeveloperMenu() throws {
        sut.start()
        // WHEN the showDeveloperMenu method is called
        sut.openDeveloperMenu()
        // THEN the presented view controller is the DeveloperMenuViewController
        let presentedViewController = try XCTUnwrap(sut.root.presentedViewController as? UINavigationController)
        XCTAssertTrue(presentedViewController.topViewController is DeveloperMenuViewController)
    }
}
