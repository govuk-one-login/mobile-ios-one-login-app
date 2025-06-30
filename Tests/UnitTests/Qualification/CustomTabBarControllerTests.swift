import CRIOrchestrator
@testable import OneLogin
import XCTest

final class CustomTabBarControllerTests: XCTestCase {
    private var sut: CustomTabBarController!
    private var idCheckNavigationController: IDCheckNavigationController!
    private var navigationController: UINavigationController!
    private var viewController: UIViewController!
    
    override func setUp() {
        super.setUp()
        sut = CustomTabBarController()
        
        idCheckNavigationController = IDCheckNavigationController()
        navigationController = UINavigationController()
        viewController = UIViewController()
        
        sut.viewControllers = [viewController]
    }
}


// Result of CustomTabBarController should match IDCheckNavigationController
extension CustomTabBarControllerTests {
    func test_shouldAutorotate_IDCheckNavigationControllerSelected() {
        sut.selectedViewController = viewController
        
        // Present IDCheckNavigationController modally
        viewController.present(idCheckNavigationController, animated: false)
        
        let result = sut.shouldAutorotate
        XCTAssertEqual(result, idCheckNavigationController.shouldAutorotate)
    }
    
    func test_preferredInterfaceOrientationForPresentation_IDCheckNavigationControllerSelected() {
        sut.selectedViewController = viewController
        
        // Present IDCheckNavigationController modally
        viewController.present(idCheckNavigationController, animated: false)
        
        let result = sut.preferredInterfaceOrientationForPresentation
        XCTAssertEqual(result, sut.preferredInterfaceOrientationForPresentation)
    }
    
    func test_supportedInterfaceOrientations_IDCheckNavigationControllerSelected() {
        sut.selectedViewController = viewController
        
        // Present IDCheckNavigationController modally
        viewController.present(idCheckNavigationController, animated: false)
        
        let result = sut.supportedInterfaceOrientations
        XCTAssertEqual(result, sut.supportedInterfaceOrientations)
    }
    
    func test_preferredStatusBarStyle_IDCheckNavigationControllerSelected() {
        sut.selectedViewController = viewController
        
        // Present IDCheckNavigationController modally
        viewController.present(idCheckNavigationController, animated: false)
        
        let result = sut.preferredStatusBarStyle
        XCTAssertEqual(result, sut.preferredStatusBarStyle)
    }
}

// Result of CustomTabBarController should match default behaviour of UITabBarController
 extension CustomTabBarControllerTests {
    func test_shouldAutorotate_OtherViewControllerPresented() {
        sut.selectedViewController = viewController
        
        // Present a UINavigationController modally
        viewController.present(navigationController, animated: false)
        
        let result = sut.shouldAutorotate
        XCTAssertEqual(result, UITabBarController().shouldAutorotate)
    }
    
    func test_preferredInterfaceOrientationForPresentation_OtherViewControllerPresented() {
        sut.selectedViewController = viewController
        
        // Present a UINavigationController modally
        viewController.present(navigationController, animated: false)
        
        let result = sut.preferredInterfaceOrientationForPresentation
        XCTAssertEqual(result, UITabBarController().preferredInterfaceOrientationForPresentation)
    }
    
    func test_supportedInterfaceOrientations_OtherViewControllerPresented() {
        sut.selectedViewController = viewController
        
        // Present a UINavigationController modally
        viewController.present(navigationController, animated: false)
        
        let result = sut.supportedInterfaceOrientations
        XCTAssertEqual(result, UITabBarController().supportedInterfaceOrientations)
    }
    
    func test_preferredStatusBarStyle_OtherViewControllerPresented() {
        sut.selectedViewController = viewController
        
        // Present a UINavigationController modally
        viewController.present(navigationController, animated: false)
        
        let result = sut.preferredStatusBarStyle
        XCTAssertEqual(result, UITabBarController().preferredStatusBarStyle)
    }
 }
