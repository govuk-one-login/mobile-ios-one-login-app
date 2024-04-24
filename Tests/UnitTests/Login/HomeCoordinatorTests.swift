@testable import OneLogin
import XCTest

@MainActor
final class HomeCoordinatorTests: XCTestCase {
    
    var sut: HomeCoordinator!
    var window: UIWindow!

    override func setUp() {
        super.setUp()
        sut = HomeCoordinator()
        window = .init()
    }

    override func tearDown() {
        sut = nil
        window = nil
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
        XCTAssertEqual(try vc.accessTokenLabel.text, "Access Token: ")
        sut.updateToken(accessToken: "testAccessToken")
        XCTAssertEqual(try vc.accessTokenLabel.text, "Access Token: testAccessToken")
    }
}
