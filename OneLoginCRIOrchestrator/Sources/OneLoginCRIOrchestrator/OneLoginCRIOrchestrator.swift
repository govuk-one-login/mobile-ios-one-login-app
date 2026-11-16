import CRIOrchestrator
import CRIOrchestratorProtocol
import UIKit

@MainActor
public class OneLoginCRIOrchestrator: CRIOrchestratorProtocol {
    private var criOrchestrator: CRIOrchestrator

    public init(
        analyticsService: IDCheckAnalyticsService,
        networkClient: IDCheckNetworkClient,
        criURLs: CRIURLs
    ) {
        self.criOrchestrator = CRIOrchestrator(
            analyticsService: analyticsService,
            networkClient: networkClient,
            criURLs: criURLs
        )
    }

    public func getIDCheckCard(
        viewController: UIViewController,
        externalStream: IDCheckExternalStream
    ) -> UIViewController {
        self.criOrchestrator.getIDCheckCard(
            viewController: viewController,
            externalStream: externalStream
        )
    }

    public func continueIdentityCheckIfRequired(over viewController: UIViewController) {
        self.criOrchestrator.continueIdentityCheckIfRequired(over: viewController)
    }
}
