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
    weak var parentCoordinator: ParentCoordinator?
    let root = UINavigationController()
    var analyticsCenter: AnalyticsCentral
    private var tokenHolder: TokenHolder
    var userStore: UserStorable
    private let urlOpener: URLOpener
    private(set) var baseVc: TabbedViewController?
    
    init(analyticsCenter: AnalyticsCentral,
         tokenHolder: TokenHolder,
         userStore: UserStorable,
         urlOpener: URLOpener,
         baseVc: TabbedViewController? = nil) {
        self.analyticsCenter = analyticsCenter
        self.tokenHolder = tokenHolder
        self.userStore = userStore
        self.urlOpener = urlOpener
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
    
    func updateToken() {
        baseVc?.updateToken(tokenHolder)
    }
    
    func openSignOutPage() {
        let navController = UINavigationController()
        let vm = SignOutPageViewModel(analyticsService: analyticsCenter.analyticsService) { [unowned self] in
            do {
                #if DEBUG
                if AppEnvironment.signoutErrorEnabled {
                    throw SecureStoreError.cantDeleteKey
                }
                #endif
                root.dismiss(animated: false) { [unowned self] in
                    tokenHolder.clearTokenHolder()
                    userStore.refreshStorage(accessControlLevel: LAContext().isPasscodeOnly ? .anyBiometricsOrPasscode : .currentBiometricsOrPasscode)
                    analyticsCenter.analyticsPreferenceStore.hasAcceptedAnalytics = nil
                    finish()
                }
            } catch {
                let errorVC = ErrorPresenter.createSignoutError(errorDescription: error.localizedDescription,
                                                                analyticsService: analyticsCenter.analyticsService) {
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
