import Coordination
import Foundation
import LocalAuthenticationWrapper

@MainActor
struct OneLoginEnrolmentManager {
    let localAuthContext: LocalAuthManaging
    private let sessionManager: SessionManager
    private let analyticsService: OneLoginAnalyticsService
    private weak var coordinator: ChildCoordinator?
    
    init(
        localAuthContext: LocalAuthManaging,
        sessionManager: SessionManager,
        analyticsService: OneLoginAnalyticsService,
        coordinator: ChildCoordinator?
    ) {
        self.localAuthContext = localAuthContext
        self.sessionManager = sessionManager
        self.analyticsService = analyticsService
        self.coordinator = coordinator
    }
    
    func saveSession() {
        #if targetEnvironment(simulator)
        if sessionManager is PersistentSessionManager {
            // UI tests or running on simulator
            completeEnrolment()
            return
        }
        #endif
        // Unit tests or running on device
        Task {
            do {
                guard try await localAuthContext.promptForPermission() else {
                    return
                }
                do {
                    try sessionManager.saveSession()
                    completeEnrolment()
                } catch {
                    analyticsService.logCrash(error)
                }
            } catch LocalAuthenticationWrapperError.cancelled {
                return
            } catch {
                analyticsService.logCrash(error)
            }
        }
    }
    
    func completeEnrolment() {
        NotificationCenter.default.post(name: .enrolmentComplete)
        coordinator?.finish()
    }
}
