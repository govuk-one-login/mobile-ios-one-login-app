@_exported import CRIOrchestrator
import UIKit

// Matches signatures of public functions of CRIOrchestrator
@MainActor
public protocol CRIOrchestration {
    func getIDCheckCard(
        viewController: UIViewController,
        externalStream: IDCheckExternalStream
    ) -> UIViewController
    
    func continueIdentityCheckIfRequired(over viewController: UIViewController)
}
