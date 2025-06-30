import CRIOrchestrator
import UIKit

// This code resolves the IDCheck landscape bug, where interface rotation preferences are overridden by UITabBarController.
// CustomTabBarController ensures the correct navigation controller handles rotation.
class CustomTabBarController: UITabBarController {
    override open var shouldAutorotate: Bool {
        if let vc = self.selectedViewController?.presentedViewController, vc is IDCheckNavigationController {
            return vc.shouldAutorotate
        } else {
            return super.shouldAutorotate
        }
    }
    
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if let vc = self.selectedViewController?.presentedViewController, vc is IDCheckNavigationController {
            return vc.preferredInterfaceOrientationForPresentation
        } else {
            return super.preferredInterfaceOrientationForPresentation
        }
        
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let vc = self.selectedViewController?.presentedViewController, vc is IDCheckNavigationController {
            return vc.supportedInterfaceOrientations
        } else {
            return super.supportedInterfaceOrientations
        }
        
    }
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        if let vc = self.selectedViewController?.presentedViewController, vc is IDCheckNavigationController {
            return vc.preferredStatusBarStyle
        } else {
            return super.preferredStatusBarStyle
        }
    }
}
