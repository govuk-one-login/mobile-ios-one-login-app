import Coordination
import UIKit

final class QualifyingCoordinator: NSObject,
                                   AnyCoordinator,
                                   NavigationCoordinator,
                                   ChildCoordinator {
    
    let root: UINavigationController
    let analyticsCenter: AnalyticsCentral
    weak var parentCoordinator: ParentCoordinator?
    var windowManager: WindowManagement

    private weak var unlockScreenViewController: UnlockScreenViewController?
    private let userStore: UserStorable
    var idToken: String?
    var error: Error?
    private let tokenVerifier: TokenVerifier

    init(root: UINavigationController = .init(),
         windowManager: WindowManagement,
         userStore: UserStorable,
         analyticsCenter: AnalyticsCentral,
         tokenVerifier: TokenVerifier = JWTVerifier()) {
        self.root = root
        self.userStore = userStore
        self.analyticsCenter = analyticsCenter
        self.tokenVerifier = tokenVerifier
        self.windowManager = windowManager
        root.modalPresentationStyle = .overCurrentContext
    }

    func start() {
        windowManager.displayUnlockWindow(analyticsService: analyticsCenter.analyticsService) { [unowned self] in
            evaluateRevisit()
        }
    }

    func checkAppVersion() {
        // TODO: DCMAW-9866 - Add service to call /appInfo
        Task {
            let seconds = 1.0
            try await Task.sleep(nanoseconds: UInt64(seconds * Double(NSEC_PER_SEC)))
            evaluateRevisit()
        }
    }

    func evaluateRevisit() {
        if userStore.previouslyAuthenticatedUser != nil {
            if userStore.validAuthenticatedUser {
                fetchIdToken()
            } else {
                finish()
            }
        } else {
            finish()
        }
    }

    private func fetchIdToken() {
        Task(priority: .userInitiated) {
            await MainActor.run {
                do {
                    let idToken = try userStore.readItem(itemName: .idToken,
                                                         storage: .authenticated)
                    TokenHolder.shared.idTokenPayload = try tokenVerifier.extractPayload(idToken)
                    self.idToken = idToken
                    finish()
                } catch {
                    self.error = error
                    finish()
                }
            }
        }
    }
}
