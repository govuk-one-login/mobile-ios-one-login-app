import DesignSystem
import GDSAnalytics
import GDSCommon
import Networking
@testable import OneLogin
import SecureStore
import XCTest

extension SettingsCoordinator {
    static func make(mockNavigationController: UINavigationController? = nil,
                     mockAnalyticsService: MockAnalyticsService = MockAnalyticsService(),
                     mockSessionManager: SessionManager = MockSessionManager()) -> SettingsCoordinator {
        let root = mockNavigationController ?? UINavigationController()
        let window = UIWindow()
        let mockNetworkClient = NetworkClient()
        mockNetworkClient.authorizationProvider = MockAuthenticationProvider()
        let urlOpener = MockURLOpener()
        window.rootViewController = root
        window.makeKeyAndVisible()

        return SettingsCoordinator(root: root,
                                   analyticsService: mockAnalyticsService,
                                   sessionManager: mockSessionManager,
                                   networkingService: mockNetworkClient,
                                   urlOpener: urlOpener)
    }
}

@MainActor
final class SettingsCoordinatorTests: XCTestCase {
    func test_tabBarItem(){
        let sut: SettingsCoordinator = .make()
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
        let mockAnalyticsService = MockAnalyticsService()
        let sut: SettingsCoordinator = .make(mockAnalyticsService: mockAnalyticsService)
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        sut.didBecomeSelected()
        let event = IconEvent(textKey: "app_settingsTitle")
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, event.parameters)
    }
    
    func test_openSignOutPage() throws {
        // WHEN the SettingsCoordinator is started
        let sut: SettingsCoordinator = .make()
        sut.start()
        // WHEN the openSignOutPage method is called
        sut.openSignOutPage()
        // THEN the presented view controller's view model is the SignOutConfirmationViewModel
        let presentedVC = try XCTUnwrap(sut.root.presentedViewController as? UINavigationController)
        let viewController = try XCTUnwrap(presentedVC.topViewController as? GDSScreen)
        XCTAssertTrue(viewController.viewModel is SignOutConfirmationViewModel)
    }
    
    func test_tapSignoutClearsData() async throws {
        let exp = XCTNSNotificationExpectation(
            name: .userDidLogout,
            object: nil,
            notificationCenter: NotificationCenter.default
        )
        let mockSessionManager = MockSessionManager()
        let sut: SettingsCoordinator = .make(mockSessionManager: mockSessionManager)
        // GIVEN the user is on the signout page
        sut.start()
        // WHEN the openSignOutPage method is called
        sut.openSignOutPage()
        let presentedVC = try XCTUnwrap(sut.root.presentedViewController as? UINavigationController)
        // WHEN the button on the screen is hit
        let viewController = try XCTUnwrap(presentedVC.topViewController as? GDSScreen)
        let viewModel = try XCTUnwrap(viewController.viewModel as? SignOutConfirmationViewModel)
        let signOutButton = viewModel.movableFooter.first as? GDSButtonViewModel
        signOutButton?.buttonAction.perform()
        
        // THEN clear all session data is called
        await fulfillment(of: [exp], timeout: 10)
        XCTAssertTrue(mockSessionManager.didCallClearAllSessionData)
    }
    
    func test_tapSignOut_errors() throws {
        let pushViewControllerExpectation = self.expectation(description: #function)
        pushViewControllerExpectation.expectedFulfillmentCount = 2

        // GIVEN an error is returned from clearAllSessionData
        let mockNavigationController = MockNavigationControllerExpectation( presentAsFunction: { _, _, _ in
            pushViewControllerExpectation.fulfill()
        })
        let mockSessionManager = MockSessionManager()
        let mockSessionManagerExpectation = MockSessionManagerExpectation(sessionManager: mockSessionManager)
        mockSessionManager.errorFromClearAllSessionData = MockWalletError.cantDelete
        let sut: SettingsCoordinator = .make(mockNavigationController: mockNavigationController,
                                             mockSessionManager: mockSessionManagerExpectation)

        // GIVEN the user is on the signout page
        sut.start()
        // WHEN the openSignOutPage method is called
        sut.openSignOutPage()
        let presentedVC = try XCTUnwrap(sut.root.presentedViewController as? UINavigationController)
        // WHEN the user signs out
        let viewController = try XCTUnwrap(presentedVC.topViewController as? GDSScreen)
        let viewModel = try XCTUnwrap(viewController.viewModel as? SignOutConfirmationViewModel)
        let signOutButton = viewModel.movableFooter.first as? GDSButtonViewModel
        signOutButton?.buttonAction.perform()
        
        wait(for: [pushViewControllerExpectation], timeout: 10)

        // THEN the presented sign out error screen is shown
        let vc = try XCTUnwrap(sut.root.presentedViewController as? GDSScreen)

        XCTAssertTrue(vc.viewModel is SignOutErrorViewModel)
    }
    
    func test_showDeveloperMenu() throws {
        let sut: SettingsCoordinator = .make()
        sut.start()
        // WHEN the showDeveloperMenu method is called
        sut.openDeveloperMenu()
        // THEN the presented view controller is the DeveloperMenuViewController
        let presentedViewController = try XCTUnwrap(sut.root.presentedViewController as? UINavigationController)
        XCTAssertTrue(presentedViewController.topViewController is DeveloperMenuViewController)
    }
}
