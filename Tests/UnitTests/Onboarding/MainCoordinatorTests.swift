import GDSCommon
@testable import OneLogin
import XCTest

@MainActor
final class MainCoordinatorTests: XCTestCase {
    var window: UIWindow!
    var navigationController: UINavigationController!
    var loginSession: MockLoginSession!
    var sut: MainCoordinator!
    
    override func setUp() {
        super.setUp()
        
        window = .init()
        navigationController = .init()
        loginSession = MockLoginSession(window: window)
        sut = MainCoordinator(root: navigationController, session: loginSession)
    }
    
    override func tearDown() {
        navigationController = nil
        loginSession = nil
        sut = nil
        
        super.tearDown()
    }
}

extension MainCoordinatorTests {
    func test_MainCoordinatorStart() throws {
        XCTAssertTrue(navigationController.viewControllers.count == 0)
        sut.start()
        XCTAssertTrue(navigationController.viewControllers.count == 1)
        XCTAssert(navigationController.topViewController is IntroViewController)
    }
}
