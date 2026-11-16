import CRIOrchestrator
import CRIOrchestratorProtocol
import OneLoginCRIOrchestrator
import Networking

extension OneLoginCRIOrchestrator {
    static func make(
        analyticsService: IDCheckAnalyticsService,
        networkClient: IDCheckNetworkClient,
        criURLs: CRIURLs
    ) -> OneLoginCRIOrchestrator {
        return OneLoginCRIOrchestrator(
            analyticsService: analyticsService,
            networkClient: networkClient,
            criURLs: criURLs
        )
    }
}
