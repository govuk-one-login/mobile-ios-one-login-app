import GDSCommon
@testable import OneLogin
import SecureStore
import XCTest

@MainActor
final class ProfileCoordinatorTests: XCTestCase {
    var window: UIWindow!
    var mockAnalyticsService: MockAnalyticsService!
    var mockSessionManager: MockSessionManager!
    var urlOpener: URLOpener!
    var sut: ProfileCoordinator!
    
    override func setUp() {
        super.setUp()

        window = .init()
        mockAnalyticsService = MockAnalyticsService()
        mockSessionManager = MockSessionManager()
        urlOpener = MockURLOpener()
        sut = ProfileCoordinator(analyticsService: mockAnalyticsService,
                                 urlOpener: urlOpener)
        window.rootViewController = sut.root
        window.makeKeyAndVisible()
    }
    
    override func tearDown() {
        window = nil
        mockAnalyticsService = nil
        mockSessionManager = nil
        urlOpener = nil
        sut = nil
        
        super.tearDown()
    }
    
    func test_tabBarItem() {
        // WHEN the ProfileCoordinator has started
        sut.start()
        let profileTab = UITabBarItem(title: "Profile",
                                      image: UIImage(systemName: "person.crop.circle"),
                                      tag: 2)
        // THEN the bar button item of the root is correctly configured
        XCTAssertEqual(sut.root.tabBarItem.title, profileTab.title)
        XCTAssertEqual(sut.root.tabBarItem.image, profileTab.image)
        XCTAssertEqual(sut.root.tabBarItem.tag, profileTab.tag)
    }
    
    func test_updateToken() throws {
        // WHEN the ProfileCoordinator is started
        sut.start()
        // THEN the email label should be nil
        let vc = try XCTUnwrap(sut.baseVc)
        XCTAssertEqual(try vc.emailLabel.text, "")
        // WHEN the update email method is called
        sut.updateUser(MockUser(email: "mock@email.com"))
        // THEN the email label should contain te email from the email token
        XCTAssertEqual(try vc.emailLabel.text, "You’re signed in as\nmock@email.com")
    }
    
    func test_openSignOutPage() throws {
        // WHEN the ProfileCoordinator is started
        sut.start()
        // WHEN the openSignOutPage method is called
        sut.openSignOutPage()
        // THEN the presented view controller is the GDSInstructionsViewController
        let presentedVC = try XCTUnwrap(sut.root.presentedViewController as? UINavigationController)
        XCTAssertTrue(presentedVC.topViewController is GDSInstructionsViewController)
    }
    
    func test_tapSignoutClearsData() throws {
        // GIVEN the user is on the signout page
        sut.start()
        // WHEN the openSignOutPage method is called
        sut.openSignOutPage()
        let presentedVC = try XCTUnwrap(sut.root.presentedViewController as? UINavigationController)
        // WHEN the user signs out
        let signOutButton: UIButton = try XCTUnwrap(presentedVC.topViewController?.view[child: "instructions-button"])
        signOutButton.sendActions(for: .touchUpInside)
        // THEN the presented view controller should be dismissed
        waitForTruth(self.sut.root.presentedViewController == nil, timeout: 20)
    }
}
