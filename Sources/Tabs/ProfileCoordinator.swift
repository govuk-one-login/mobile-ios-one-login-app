import Coordination
import GDSCommon
import Logging
import UIKit

final class ProfileCoordinator: NSObject,
                                AnyCoordinator,
                                ChildCoordinator,
                                NavigationCoordinator {
    weak var parentCoordinator: ParentCoordinator?
    let root = UINavigationController()
    var analyticsCenter: AnalyticsCentral
    var userStore: UserStorable
    private let urlOpener: URLOpener
    private(set) var baseVc: TabbedViewController?

    init(analyticsCenter: AnalyticsCentral,
         urlOpener: URLOpener,
         userStore: UserStorable,
         baseVc: TabbedViewController? = nil) {
        self.analyticsCenter = analyticsCenter
        self.urlOpener = urlOpener
        self.userStore = userStore
        self.baseVc = baseVc
    }
    
    func start() {
        root.tabBarItem = UITabBarItem(title: GDSLocalisedString(stringLiteral: "app_profileTitle").value,
                                       image: UIImage(systemName: "person.crop.circle"),
                                       tag: 2)
        let viewModel = ProfileTabViewModel(analyticsService: analyticsCenter.analyticsService,
                                            sectionModels: TabbedViewSectionFactory.profileSections(urlOpener: urlOpener,
                                                                                                    action: openSignOutPage))
        let profileViewController = TabbedViewController(viewModel: viewModel,
                                                         headerView: SignInView())
        baseVc = profileViewController
        root.setViewControllers([profileViewController], animated: true)
    }
    
    func updateToken(_ tokenHolder: TokenHolder) {
        baseVc?.updateToken(tokenHolder)
    }

    func openSignOutPage() {
        let navController = UINavigationController()
        let vm = SignOutPageViewModel(analyticsService: analyticsCenter.analyticsService) { [unowned self] in
          do {
            analyticsCenter.analyticsPreferenceStore.hasAcceptedAnalytics = false
            analyticsCenter.analyticsService.denyAnalyticsPermission()
            // TODO: DCMAW-8933 will handle sign out error scenarios
            try? userStore.clearTokenInfo()
            try? userStore.secureStoreService.delete()
            userStore.shouldPromptForAnalytics = true
              root.dismiss(animated: false) {
                  self.finish()
              }
          } catch {
            print(error.localizedDescription)
          }
        }
        let signoutPageVC = GDSInstructionsViewController(viewModel: vm)
        navController.setViewControllers([signoutPageVC], animated: true)
        root.present(navController, animated: true)
      }
}
