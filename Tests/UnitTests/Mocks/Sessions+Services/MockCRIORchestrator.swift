@testable import OneLogin
import UIKit

class MockCRIOrchestrator: CRIOrchestration {
    func continueIdentityCheckIfRequired(over viewController: UIViewController) {
        
    }
    
    func getIDCheckCard(viewController: UIViewController, completion: @escaping () -> Void) -> UIViewController {
        let vc = UIViewController()
        vc.view.isHidden = false
        return vc
    }
}
