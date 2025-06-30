import CRIOrchestrator
import UIKit

// This code resolves the IDCheck landscape bug, where interface rotation preferences are overridden by UITabBarController.
// CustomTabBarController ensures the correct navigation controller handles rotation.
class CustomTabBarController: UITabBarController {
    override open var shouldAutorotate: Bool {
        get {
            if let vc = self.selectedViewController?.presentedViewController, vc is IDCheckNavigationController {
                return vc.shouldAutorotate
            } else {
                return super.shouldAutorotate
            }
        }
        set {
            // Empty implementation
        }
    }
    
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        get {
            if let vc = self.selectedViewController?.presentedViewController, vc is IDCheckNavigationController {
                return vc.preferredInterfaceOrientationForPresentation
            } else {
                return super.preferredInterfaceOrientationForPresentation
            }
        }
        set {
            // Empty implementation
        }
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            if let vc = self.selectedViewController?.presentedViewController, vc is IDCheckNavigationController {
                return vc.supportedInterfaceOrientations
            } else {
                return super.supportedInterfaceOrientations
            }
        }
        set {
            // Empty implementation
        }
    }
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            if let vc = self.selectedViewController?.presentedViewController, vc is IDCheckNavigationController {
                return vc.preferredStatusBarStyle
            } else {
                return super.preferredStatusBarStyle
            }
        }
        set {
            // Empty implementation
        }
    }
}
