import Coordination
import Logging
import UIKit

final class OnboardingCoordinator: NSObject,
                                   AnyCoordinator,
                                   ChildCoordinator {
    let root = UINavigationController()
    var parentCoordinator: ParentCoordinator?
    var analyticsPreferenceStore: AnalyticsPreferenceStore
    private let viewControllerFactory = OnboardingViewControllerFactory.self
    
    init(analyticsPreferenceStore: AnalyticsPreferenceStore) {
        self.analyticsPreferenceStore = analyticsPreferenceStore
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
            }
        root.setViewControllers([analyticsPreferenceScreen], animated: false)
    }
}
