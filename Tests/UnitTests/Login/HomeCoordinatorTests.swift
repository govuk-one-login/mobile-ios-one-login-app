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
}
