import CRIOrchestrator
import CRIOrchestratorProtocol
import UIKit

@MainActor
public class OneLoginCRIOrchestrator: CRIOrchestratorProtocol {
    private var orchestrator: CRIOrchestrator

    public init(
        analyticsService: IDCheckAnalyticsService,
        networkClient: IDCheckNetworkClient,
        criURLs: CRIURLs
    ) {
        self.orchestrator = CRIOrchestrator(analyticsService: analyticsService,
                                            networkClient: networkClient,
                                            criURLs: criURLs)
    }

    public func getIDCheckCard(viewController: UIViewController,
                        externalStream: IDCheckExternalStream
    ) -> UIViewController {
        self.orchestrator.getIDCheckCard(viewController: viewController, externalStream: externalStream)
    }

    public func continueIdentityCheckIfRequired(over viewController: UIViewController) {
        self.orchestrator.continueIdentityCheckIfRequired(over: viewController)
    }
}
