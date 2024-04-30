import Coordination
import GDSCommon
import UIKit

final class ProfileCoordinator: NSObject,
                                AnyCoordinator,
                                ChildCoordinator,
                                NavigationCoordinator {
    var parentCoordinator: ParentCoordinator?
    let root: UINavigationController
    private let urlOpener: URLOpener
    private (set)var baseVc: TabbedViewController?
    
    init(parentCoordinator: ParentCoordinator? = nil,
         root: UINavigationController = UINavigationController(),
         urlOpener: URLOpener,
         baseVc: TabbedViewController? = nil) {
        self.parentCoordinator = parentCoordinator
        self.root = root
        self.urlOpener = urlOpener
        self.baseVc = baseVc
    }
    
    func start() {
        let viewModel = TabbedViewModel(title: "app_profileTitle",
                                        sectionModels: createSectionModels())
        let profileViewController = TabbedViewController(viewModel: viewModel,
                                                         headerView: SignInView(viewModel: SignInViewModel()))
        baseVc = profileViewController
        root.setViewControllers([profileViewController], animated: true)
    }
    
    func updateToken(accessToken: String?) {
        baseVc?.updateToken(accessToken: accessToken)
    }
    
    private func createSectionModels() -> [TabbedViewSectionModel] {
        let manageDetailsCell = TabbedViewCellModel(cellTitle: "app_manageSignInDetailsLink",
                                                    accessoryView: "arrow.up.right") {
            self.urlOpener.open(url: AppEnvironment.manageAccountURL)
        }
        
        let manageDetailsSection = TabbedViewSectionModel(sectionTitle: "app_profileSubtitle1",
                                                          sectionFooter: "app_manageSignInDetailsFootnote",
                                                          tabModels: [manageDetailsCell])
        
        let privacyPolicyCell = TabbedViewCellModel(cellTitle: "app_privacyNoticeLink2",
                                                    accessoryView: "arrow.up.right") {
            self.urlOpener.open(url: AppEnvironment.privacyPolicyURL)
        }
        
        let legalSection = TabbedViewSectionModel(sectionTitle: "app_profileSubtitle2",
                                                  tabModels: [privacyPolicyCell])
        
        let helpSection = TabbedViewSectionFactory.createSection(header: "app_profileSubtitle3",
                                                                 footer: nil,
                                                                 cellModels: [.init(cellTitle: "app_reportAProblemGiveFeedbackLink",
                                                                                    accessoryView: "arrow.up.right"),
                                                                              .init(cellTitle: "app_appGuidanceLink",
                                                                                   accessoryView: "arrow.up.right")])
        let signoutSection = TabbedViewSectionFactory.createSection(header: nil,
                                                                    footer: nil,
                                                                    cellModels: [.init(cellTitle: "app_signOutButton",
                                                                                       textColor: .systemRed)])
        
        return [manageDetailsSection,
                legalSection,
                helpSection,
                signoutSection]
    }

}
