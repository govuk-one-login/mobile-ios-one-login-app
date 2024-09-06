import Networking
@testable import OneLogin
import XCTest

final class HomeCoordinatorTests: XCTestCase {
    var window: UIWindow!
    var mockAnalyticsService: MockAnalyticsService!
    var mockSessionManager: MockSessionManager!
    var sut: HomeCoordinator!
    
    @MainActor
    override func setUp() {
        super.setUp()

        window = UIWindow()
        mockAnalyticsService = MockAnalyticsService()
        mockSessionManager = MockSessionManager()
        sut = HomeCoordinator(analyticsService: mockAnalyticsService,
                              networkClient: NetworkClient(),
                              sessionManager: mockSessionManager)
    }
    
    override func tearDown() {
        window = nil
        mockAnalyticsService = nil
        mockSessionManager = nil
        sut = nil
        
        super.tearDown()
    }
    
    @MainActor
    func test_tabBarItem() throws {
        // WHEN the HomeCoordinator has started
        sut.start()
        // THEN the bar button item of the root is correctly configured
        let homeTab = UITabBarItem(title: "Home",
                                   image: UIImage(systemName: "house"),
                                   tag: 0)
        XCTAssertEqual(sut.root.tabBarItem.title, homeTab.title)
        XCTAssertEqual(sut.root.tabBarItem.image, homeTab.image)
        XCTAssertEqual(sut.root.tabBarItem.tag, homeTab.tag)
    }
    
    @MainActor
    func test_showDeveloperMenu() throws {
        window.rootViewController = sut.root
        window.makeKeyAndVisible()
        sut.start()
        // WHEN the showDeveloperMenu method is called
        sut.showDeveloperMenu()
        // THEN the presented view controller is the DeveloperMenuViewController
        let presentedViewController = try XCTUnwrap(sut.root.presentedViewController as? UINavigationController)
        XCTAssertTrue(presentedViewController.topViewController is DeveloperMenuViewController)
    }
    
    @MainActor
    func test_updateToken() throws {
        // WHEN the HomeCoordinator is started
        sut.start()
        let vc = try XCTUnwrap(sut.baseVc)
        // THEN the email label should be nil
        XCTAssertEqual(try vc.emailLabel.text, "")
        // WHEN the updateUser method is called
        let user = MockUser()
        sut.updateUser(user)
        // THEN the email label should contain te email from the email token
        XCTAssertEqual(try vc.emailLabel.text, "You’re signed in as\ntest@example.com")
    }
}
