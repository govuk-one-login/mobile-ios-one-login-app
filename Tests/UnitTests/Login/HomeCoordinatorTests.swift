@testable import OneLogin
import XCTest

@MainActor
final class HomeCoordinatorTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var window: UIWindow!
    var sut: HomeCoordinator!

    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        window = .init()
        sut = HomeCoordinator(analyticsService: mockAnalyticsService)
    }

    override func tearDown() {
        mockAnalyticsService = nil
        window = nil
        sut = nil
        
        super.tearDown()
    }

    func test_showDeveloperMenu() throws {
        sut.start()
        window.rootViewController = sut.root
        window.makeKeyAndVisible()
        sut.showDeveloperMenu()
        let presentedViewController = try XCTUnwrap(sut.root.presentedViewController as? UINavigationController)
        XCTAssertTrue( presentedViewController.topViewController is DeveloperMenuViewController)
    }
    
    func test_updateToken() throws {
        sut.start()
        let vc = try XCTUnwrap(sut.baseVc)
        XCTAssertEqual(try vc.emailLabel.text, nil)
        sut.updateToken(accessToken: "testAccessToken")
        XCTAssertEqual(try vc.emailLabel.text, "You’re signed in as\nexample@email.com")
    }
}
