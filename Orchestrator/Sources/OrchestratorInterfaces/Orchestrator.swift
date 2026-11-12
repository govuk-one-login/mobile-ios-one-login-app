import UIKit
import CRIOrchestrator
import Coordination

@MainActor
public protocol Orchestrator {
    func continueIdentityCheckIfRequired(over viewController: UIViewController)

    func getIDCheckCard(
        viewController: UIViewController,
        externalStream: IDCheckExternalStream
    ) -> UIViewController
}
