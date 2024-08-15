import Coordination
import UIKit

final class QualifyingCoordinator: NSObject,
                                   AnyCoordinator,
                                   NavigationCoordinator,
                                   ChildCoordinator {
    
    let root: UINavigationController
    var analyticsCenter: AnalyticsCentral
    weak var parentCoordinator: ParentCoordinator?
    var childCoordinators = [ChildCoordinator]()

    private weak var unlockScreenViewController: UnlockScreenViewController?

    init(root: UINavigationController = .init(), analyticsCenter: AnalyticsCentral) {
        self.root = root
        self.analyticsCenter = analyticsCenter
    }

    func start() {
        // TODO: DCMAW-9866 - Change to factory call to display unlock screen?
        let unlockScreenViewModel = UnlockScreenViewModel(analyticsService: analyticsCenter.analyticsService) {
//            call to local auth unlock stuff
        }
        let vc = UnlockScreenViewController(viewModel: unlockScreenViewModel)
        unlockScreenViewController = vc
        vc.modalPresentationStyle = .fullScreen
        root.present(vc, animated: false) {
            self.checkAppVersion()
        }
    }

    func checkAppVersion() {
        // TODO: DCMAW-9866 - Add service to call /appInfo
        sleep(3)
        unlockScreenViewController?.finishLoading()
    }
}
