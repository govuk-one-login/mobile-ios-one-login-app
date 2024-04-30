import Coordination
import GDSCommon
import Networking
import UIKit

final class HomeCoordinator: NSObject,
                             AnyCoordinator,
                             ChildCoordinator,
                             NavigationCoordinator {
    var parentCoordinator: ParentCoordinator?
    var root = UINavigationController()
    var networkClient: NetworkClient?
    private var accessToken: String?
    private(set) var baseVc: TabbedViewController?
    
    func start() {
        let viewModel = TabbedViewModel(title: "app_homeTitle",
                                        sectionHeaderTitles: createSectionHeaders(),
                                        cellModels: createCellModels())
        let hc = TabbedViewController(viewModel: viewModel,
                                      headerView: SignInView(viewModel: SignInViewModel()))
        baseVc = hc
        root.setViewControllers([hc], animated: true)
    }
    
    func updateToken(accessToken: String?) {
        baseVc?.updateToken(accessToken: accessToken)
    }
    
    func showDeveloperMenu() {
        let navController = UINavigationController()
        let devMenuViewModel = DeveloperMenuViewModel()
        let developerMenuVC = DeveloperMenuViewController(viewModel: devMenuViewModel,
                                                          networkClient: networkClient)
        navController.setViewControllers([developerMenuVC], animated: true)
        root.present(navController, animated: true)
    }
    
    private func createCellModels() -> [[TabbedViewCellModel]] {
        #if DEBUG
        let developerModel = TabbedViewCellModel(cellTitle: "Developer Menu") { [unowned self] in
            showDeveloperMenu()
        }
        #else
        let developerModel = TabbedViewCellModel()
        #endif
        
        return [[developerModel]]
    }
    
    private func createSectionHeaders() -> [GDSLocalisedString] {
        #if DEBUG
        ["Developer Menu"]
        #else
        [GDSLocalisedString]()
        #endif
    }
}
