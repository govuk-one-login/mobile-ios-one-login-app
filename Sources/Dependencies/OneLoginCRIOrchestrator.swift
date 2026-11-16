import CRIOrchestrator
import CRIOrchestratorProtocol
import Networking
import OneLoginCRIOrchestrator

extension OneLoginCRIOrchestrator {
    static func make(
        analyticsService: IDCheckAnalyticsService,
        networkClient: IDCheckNetworkClient,
        criURLs: CRIURLs
    ) -> CRIOrchestratorProtocol {
        let criOrchestrator = CRIOrchestrator(
            analyticsService: analyticsService,
            networkClient: networkClient,
            criURLs: criURLs
        )
        
        return OneLoginCRIOrchestrator(criOrchestrator: criOrchestrator)
    }
}
