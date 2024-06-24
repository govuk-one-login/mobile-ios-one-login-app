import Coordination
import GDSCommon
import LocalAuthentication
import Logging
import SecureStore
import UIKit

final class ProfileCoordinator: NSObject,
                                AnyCoordinator,
                                ChildCoordinator,
                                NavigationCoordinator {
    let root = UINavigationController()
    weak var parentCoordinator: ParentCoordinator?
    var analyticsService: AnalyticsService
    var userStore: UserStorable
    private var tokenHolder: TokenHolder
    private let urlOpener: URLOpener
    private(set) var baseVc: TabbedViewController?
    
    init(analyticsService: AnalyticsService,
         userStore: UserStorable,
         tokenHolder: TokenHolder,
         urlOpener: URLOpener,
         baseVc: TabbedViewController? = nil) {
        self.analyticsService = analyticsService
        self.userStore = userStore
        self.tokenHolder = tokenHolder
        self.urlOpener = urlOpener
        self.baseVc = baseVc
    }
    
    func start() {
        root.tabBarItem = UITabBarItem(title: GDSLocalisedString(stringLiteral: "app_profileTitle").value,
                                       image: UIImage(systemName: "person.crop.circle"),
                                       tag: 2)
        let viewModel = ProfileTabViewModel(analyticsService: analyticsService,
                                            sectionModels: TabbedViewSectionFactory.profileSections(urlOpener: urlOpener,
                                                                                                    action: openSignOutPage))
        let profileViewController = TabbedViewController(viewModel: viewModel,
                                                         headerView: SignInView())
        baseVc = profileViewController
        root.setViewControllers([profileViewController], animated: true)
    }
    
    func updateToken() {
        baseVc?.updateToken(tokenHolder)
    }
    
    func openSignOutPage() {
        let navController = UINavigationController()
        let vm = SignOutPageViewModel(analyticsService: analyticsService) { [unowned self] in
            do {
                #if DEBUG
                if AppEnvironment.signoutErrorEnabled {
                    throw SecureStoreError.cantDeleteKey
                }
                #endif
                root.dismiss(animated: false) { [unowned self] in
                    finish()
                }
            } catch {
                let errorVC = ErrorPresenter.createSignoutError(errorDescription: error.localizedDescription,
                                                                analyticsService: analyticsService) {
                    exit(0)
                }
                navController.pushViewController(errorVC, animated: true)
            }
        }
        let signoutPageVC = GDSInstructionsViewController(viewModel: vm)
        navController.setViewControllers([signoutPageVC], animated: true)
        root.present(navController, animated: true)
    }
}
