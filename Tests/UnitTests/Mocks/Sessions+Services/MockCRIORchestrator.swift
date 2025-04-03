@testable import OneLogin
import UIKit

class MockCRIOrchestrator: CRIOrchestration {
    private var hostingViewController: UIViewController = UIViewController()
    
    func continueIdentityCheckIfRequired(over viewController: UIViewController) {
        hostingViewController.view.isHidden = false
    }
    
    func getIDCheckCard(viewController: UIViewController, completion: @escaping () -> Void) -> UIViewController {
        hostingViewController.view.isHidden = true
        return hostingViewController
    }
}
