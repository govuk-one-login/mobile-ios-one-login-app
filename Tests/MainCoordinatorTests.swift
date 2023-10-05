import GDSCommon
@testable import OneLogin
import XCTest

@MainActor
final class MainCoordinatorTests: XCTestCase {
    var window: UIWindow!
    var navigationController: UINavigationController!
    var sut: MainCoordinator!
    
    override func setUp() {
        super.setUp()
        
        window = .init()
        navigationController = .init()
        sut = .init(window: window, root: navigationController)
    }
    
    override func tearDown() {
        window = nil
        navigationController = nil
        sut = nil
        
        super.tearDown()
    }
}

extension MainCoordinatorTests {
    func test_MainCoordinatorStart() throws {
        XCTAssertTrue(navigationController.viewControllers.count == 0)
        sut.start()
        XCTAssertTrue(navigationController.viewControllers.count == 1)
        XCTAssert(navigationController.topViewController is WelcomeViewController)
    }
}
