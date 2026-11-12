import Networking
import CRIOrchestrator

#if MOCK
import MockOrchestrator
import OrchestratorInterfaces

typealias OneLoginOrchestrator = MockOrchestrator
#else
import CRIOrchestrator
import Orchestrator
import OrchestratorInterfaces

typealias OneLoginOrchestrator = CRIOrchestratorWrapper
#endif

extension Orchestrator {
    static func make(analyticsService: IDCheckAnalyticsService,
                     networkClient: IDCheckNetworkClient,
                     criURLs: CRIURLs) -> Orchestrator {
    #if MOCK
        return MockCRIOrchestrator()
    #else
        return CRIOrchestratorWrapper(
            analyticsService:analyticsService,
            networkClient: networkClient,
            criURLs: criURLs)
    #endif
    }
}
