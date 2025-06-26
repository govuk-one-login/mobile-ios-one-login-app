import Coordination
import GDSCommon
import Logging
import UIKit

final class OnboardingCoordinator: NSObject,
                                   AnyCoordinator,
                                   ChildCoordinator {
    let root = UINavigationController()
    weak var parentCoordinator: ParentCoordinator?
    private var analyticsService: OneLoginAnalyticsService
    private var analyticsPreferenceStore: AnalyticsPreferenceStore
    private let urlOpener: URLOpener
    
    init(analyticsService: OneLoginAnalyticsService,
         analyticsPreferenceStore: AnalyticsPreferenceStore,
         urlOpener: URLOpener) {
        self.analyticsService = analyticsService
        self.analyticsPreferenceStore = analyticsPreferenceStore
        self.urlOpener = urlOpener
    }
    
    func start() {
        let viewModel = AnalyticsPreferenceViewModel { [unowned self] in
            analyticsService.grantAnalyticsPermission()
            analyticsPreferenceStore.hasAcceptedAnalytics = true
            root.dismiss(animated: true)
            finish()
        } secondaryButtonAction: { [unowned self] in
            analyticsService.denyAnalyticsPermission()
            analyticsPreferenceStore.hasAcceptedAnalytics = false
            root.dismiss(animated: true)
            finish()
        } textButtonAction: { [unowned self] in
            urlOpener.open(url: AppEnvironment.privacyPolicyURL)
        }
        let analyticsPreferenceScreen = ModalInfoViewController(viewModel: viewModel)
        root.setViewControllers([analyticsPreferenceScreen], animated: false)
    }
}
