import XCTest

class MockNavigationControllerExpectation: UINavigationController {
    
    typealias PushViewControllerAsFunction = (UIViewController, Bool) -> Void
    typealias PresentAsFunction = (UIViewController, Bool, (() -> Void)?) -> Void
    
    var pushViewControllerAsFunction: PushViewControllerAsFunction
    var presentAsFunction: PresentAsFunction

    
    init(pushViewControllerAsFunction: @escaping PushViewControllerAsFunction = { _, _ in }, presentAsFunction: @escaping PresentAsFunction = { _, _, _ in }) {
        self.pushViewControllerAsFunction = pushViewControllerAsFunction
        self.presentAsFunction = presentAsFunction
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.pushViewControllerAsFunction = { _, _ in }
        self.presentAsFunction = { _, _, _ in }
        super.init(coder: aDecoder)
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        self.pushViewControllerAsFunction(viewController, animated)
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        super.present(viewControllerToPresent, animated: flag, completion: completion)
        self.presentAsFunction(viewControllerToPresent, flag, completion)
    }
}
