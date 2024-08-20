import Coordination
import UIKit

final class QualifyingCoordinator: NSObject,
                                   AnyCoordinator,
                                   NavigationCoordinator,
                                   ChildCoordinator {
    
    let root: UINavigationController
    let analyticsCenter: AnalyticsCentral
    weak var parentCoordinator: ParentCoordinator?

    private weak var unlockScreenViewController: UnlockScreenViewController?
    private weak var mainCoordinator: MainCoordinator?
    private let userStore: UserStorable
    var idToken: String?

    init(root: UINavigationController = .init(),
         userStore: UserStorable,
         analyticsCenter: AnalyticsCentral) {
        self.root = root
        self.userStore = userStore
        self.analyticsCenter = analyticsCenter
        root.modalPresentationStyle = .overCurrentContext
    }

    func start() {
        // TODO: DCMAW-9866 - Change to factory call to display unlock screen?
        let unlockScreenViewModel = UnlockScreenViewModel(analyticsService: analyticsCenter.analyticsService) {
            print("unlock button tapped")
            // WILL DO SOMETHING
        }
        let vc = UnlockScreenViewController(viewModel: unlockScreenViewModel)
        unlockScreenViewController = vc
        root.setViewControllers([vc], animated: false)
                checkAppVersion()
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
                    self.idToken = idToken
                    finish()
                } catch {
                    finish()
                }
            }
        }
    }
}
