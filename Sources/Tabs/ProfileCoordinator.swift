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
    let analyticsService: AnalyticsService
    private let urlOpener: URLOpener
    private(set) var baseVc: TabbedViewController?
    
    init(analyticsService: AnalyticsService,
         urlOpener: URLOpener,
         baseVc: TabbedViewController? = nil) {
        self.analyticsService = analyticsService
        self.urlOpener = urlOpener
        self.baseVc = baseVc
    }
    
    func start() {
        root.tabBarItem = UITabBarItem(title: GDSLocalisedString(stringLiteral: "app_profileTitle").value,
                                       image: UIImage(systemName: "person.crop.circle"),
                                       tag: 2)
        let viewModel = ProfileTabViewModel(analyticsService: analyticsService,
                                            sectionModels: TabbedViewSectionFactory.profileSections(urlOpener: urlOpener))
        let profileViewController = TabbedViewController(viewModel: viewModel,
                                                         headerView: SignInView(viewModel: SignInViewModel()))
        baseVc = profileViewController
        root.setViewControllers([profileViewController], animated: true)
    }
    
    func updateToken(accessToken: String?) {
        baseVc?.updateToken(accessToken: accessToken)
    }
}
