import Coordination
import GDSCommon
import UIKit

final class HomeCoordinator: NSObject,
                             AnyCoordinator,
                             ChildCoordinator,
                             NavigationCoordinator {
    var parentCoordinator: ParentCoordinator?
    var root = UINavigationController()
    private var accessToken: String?
    private (set)var baseVc: TabbedViewController?

    func start() {
        let tokensViewModel = TokensViewModel {
            self.showDeveloperMenu()
        }

        
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
        let developerMenuVC = DeveloperMenuViewController()
        navController.setViewControllers([developerMenuVC], animated: true)
        root.present(navController, animated: true)
    }
    
    private func createCellModels() -> [[TabbedViewCellModel]] {
        #if DEBUG
        let developerModel = TabbedViewCellModel(cellTitle: GDSLocalisedString(stringLiteral: "Developer Menu")) {
            self.showDeveloperMenu()
        }
        #else
        let developerModel = TabbedViewCellModel()
        #endif
        
        return [[developerModel]]
    }
    
    private func createSectionHeaders() -> [GDSLocalisedString] {
        #if DEBUG
        [GDSLocalisedString(stringLiteral: "Developer Menu")]
        #else
        [GDSLocalisedString]()
        #endif
    }
}
