import CRIOrchestrator
@testable import OneLogin
import SDKInterface
import UIKit

class MockCRIOrchestrator: CRIOrchestration {
    var idCheckJourney = false
    var streamContinuation: AsyncStream<CardStatus>.Continuation?
    var hostingViewController = UIViewController()
    
    func continueIdentityCheckIfRequired(over viewController: UIViewController) {}
    
    func getIDCheckCard(
        viewController: UIViewController,
        externalStream: IDCheckExternalStream
    ) -> UIViewController {
        streamContinuation = externalStream.continuation
        hostingViewController.view.isHidden = !idCheckJourney
        return hostingViewController
    }
}
