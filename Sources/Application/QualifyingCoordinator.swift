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
//    var isNewUser = false
    var idToken: String?

    init(root: UINavigationController = .init(),
         userStore: UserStorable,
         analyticsCenter: AnalyticsCentral) {
        self.root = root
        self.userStore = userStore
        self.analyticsCenter = analyticsCenter
    }

    func start() {
        // TODO: DCMAW-9866 - Change to factory call to display unlock screen?
        let unlockScreenViewModel = UnlockScreenViewModel(analyticsService: analyticsCenter.analyticsService) {
            print("unlock button tapped")
            // WILL DO SOMETHING
        }
        let vc = UnlockScreenViewController(viewModel: unlockScreenViewModel)
        unlockScreenViewController = vc
        vc.modalPresentationStyle = .fullScreen
        root.present(vc, animated: false) {
            print("checking app version")
            self.checkAppVersion()
        }
    }

    func checkAppVersion() {
        // TODO: DCMAW-9866 - Add service to call /appInfo
        sleep(3)
        unlockScreenViewController?.finishLoading()
        evaluateRevisit()
    }

    func evaluateRevisit() {
        if userStore.previouslyAuthenticatedUser != nil {
            if userStore.validAuthenticatedUser {
                // should be prompted for Face/Touch ID
                fetchIdToken()
            } else {
                finish()
            }
        } else {
//            !userStore.previouslyAuthenticatedUser
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
