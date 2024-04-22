import Coordination
import GDSCommon
import Logging
import UIKit

final class OnboardingCoordinator: NSObject,
                                   AnyCoordinator,
                                   ChildCoordinator {
    let root = UINavigationController()
    
    var parentCoordinator: ParentCoordinator?
    private let urlOpener: URLOpener
    private let privacyURL: URL?
    private var analyticsPreferenceStore: AnalyticsPreferenceStore
    private let viewControllerFactory = OnboardingViewControllerFactory.self
    
    init(analyticsPreferenceStore: AnalyticsPreferenceStore,
         urlOpener: URLOpener,
         privacyURL: URL?) {
        self.analyticsPreferenceStore = analyticsPreferenceStore
        self.urlOpener = urlOpener
        self.privacyURL = privacyURL
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
                guard let url = privacyURL else { return }
                urlOpener.open(url: url)
            }
        root.setViewControllers([analyticsPreferenceScreen], animated: false)
    }
}
