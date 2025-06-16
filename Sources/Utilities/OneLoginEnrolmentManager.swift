import Coordination
import Foundation
import LocalAuthenticationWrapper
import Wallet

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
    
    func saveSession(isWalletEnrolment: Bool = false, completion: (() -> Void)? = nil) {
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
                    completeEnrolment(isWalletEnrolment: isWalletEnrolment, completion: completion)
                } catch {
                    analyticsService.logCrash(error)
                }
            } catch LocalAuthenticationWrapperError.cancelled {
                (coordinator as? EnrolmentCoordinator)?
                    .enableEnrolmentButton()
                (coordinator as? WalletCoordinator)?
                    .userCancelledPasscode()
            } catch {
                analyticsService.logCrash(error)
            }
        }
    }
    
    func completeEnrolment(isWalletEnrolment: Bool = false, completion: (() -> Void)? = nil) {
        if !isWalletEnrolment {
            NotificationCenter.default.post(name: .enrolmentComplete)
        }
        completion?()
        coordinator?.finish()
    }
}
