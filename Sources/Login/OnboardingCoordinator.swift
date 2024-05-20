import Coordination
import GDSCommon
import Logging
import UIKit

final class OnboardingCoordinator: NSObject,
                                   AnyCoordinator,
                                   ChildCoordinator {
    let root = UINavigationController()
    weak var parentCoordinator: ParentCoordinator?
    private var analyticsPreferenceStore: AnalyticsPreferenceStore
    private let urlOpener: URLOpener
    private let viewControllerFactory = OnboardingViewControllerFactory.self
    
    init(analyticsPreferenceStore: AnalyticsPreferenceStore,
         urlOpener: URLOpener) {
        self.analyticsPreferenceStore = analyticsPreferenceStore
        self.urlOpener = urlOpener
    }
    
    func start() {
        let analyticsPreferenceScreen = viewControllerFactory
            .createAnalyticsPeferenceScreen { [unowned self] in
                analyticsPreferenceStore.hasAcceptedAnalytics = true
                root.dismiss(animated: true)
                finish()
            } secondaryButtonAction: { [unowned self] in
                analyticsPreferenceStore.hasAcceptedAnalytics = false
                root.dismiss(animated: true)
                finish()
            } textButtonAction: { [unowned self] in
                urlOpener.open(url: AppEnvironment.privacyPolicyURL)
            }
        root.setViewControllers([analyticsPreferenceScreen], animated: false)
    }
}
