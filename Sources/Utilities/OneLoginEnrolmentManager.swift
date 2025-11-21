import Coordination
import Foundation
import LocalAuthenticationWrapper
import Wallet

@MainActor
protocol EnrolmentManager {
    var localAuthContext: LocalAuthManaging { get }
    var sessionManager: SessionManager { get }
    var analyticsService: OneLoginAnalyticsService { get }
    var coordinator: ChildCoordinator? { get }
    
    init(
        localAuthContext: LocalAuthManaging,
        sessionManager: SessionManager,
        analyticsService: OneLoginAnalyticsService,
        coordinator: ChildCoordinator?
    )
    
    func saveSession(isWalletEnrolment: Bool, completion: (() -> Void)?)
    func completeEnrolment(isWalletEnrolment: Bool, completion: (() -> Void)?)
}

struct OneLoginEnrolmentManager: EnrolmentManager {
    let localAuthContext: LocalAuthManaging
    let sessionManager: SessionManager
    let analyticsService: OneLoginAnalyticsService
    weak var coordinator: ChildCoordinator?
    
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
                    try sessionManager.saveAuthSession()
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
