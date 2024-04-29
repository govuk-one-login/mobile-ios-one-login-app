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
                                        sectionHeaderTitles: [GDSLocalisedString(stringLiteral: "Developer Menu")],
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
        let developerModel = TabbedViewCellModel(cellTitle: GDSLocalisedString(stringLiteral: "Developer Menu")) {
            self.showDeveloperMenu()
        }
        return [[developerModel]]
    }
}
