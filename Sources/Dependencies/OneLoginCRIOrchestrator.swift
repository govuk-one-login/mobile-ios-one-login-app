import CRIOrchestrator
import CRIOrchestratorProtocol
import Networking
import OneLoginCRIOrchestrator

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
