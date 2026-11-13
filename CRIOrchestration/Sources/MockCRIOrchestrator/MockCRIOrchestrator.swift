import CRIOrchestrator
import CRIOrchestratorInterface
import UIKit

public class MockCRIOrchestrator: CRIOrchestration {
    var idCheckJourney = false
    var streamContinuation: AsyncStream<CardStatus>.Continuation?
    var hostingViewController = UIViewController()
    
    public init(
        idCheckJourney: Bool = false,
        streamContinuation: AsyncStream<CardStatus>.Continuation? = nil,
        hostingViewController: UIViewController = UIViewController()
    ) {
        self.idCheckJourney = idCheckJourney
        self.streamContinuation = streamContinuation
        self.hostingViewController = hostingViewController
    }
    
    public func getIDCheckCard(
        viewController: UIViewController,
        externalStream: IDCheckExternalStream
    ) -> UIViewController {
        streamContinuation = externalStream.continuation
        hostingViewController.view.isHidden = !idCheckJourney
        
        return hostingViewController
    }
    
    public func continueIdentityCheckIfRequired(over viewController: UIViewController) {}
}
