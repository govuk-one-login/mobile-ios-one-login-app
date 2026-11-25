import Coordination
import DesignSystem
import Logging
import UIKit

final class OnboardingCoordinator: NSObject,
                                   AnyCoordinator,
                                   ChildCoordinator {
    let root = UINavigationController()
    weak var parentCoordinator: ParentCoordinator?
    private var analyticsPreferenceStore: AnalyticsPreferenceStore
    private let urlOpener: URLOpener
    
    init(
        analyticsPreferenceStore: AnalyticsPreferenceStore,
        urlOpener: URLOpener
    ) {
        self.analyticsPreferenceStore = analyticsPreferenceStore
        self.urlOpener = urlOpener
    }
    
    func start() {
        let viewModel = AnalyticsPreferenceViewModel { [weak self] in
            self?.analyticsPreferenceStore.hasAcceptedAnalytics = true
            self?.root.dismiss(animated: true)
            self?.finish()
        } secondaryButtonAction: { [weak self] in
            self?.analyticsPreferenceStore.hasAcceptedAnalytics = false
            self?.root.dismiss(animated: true)
            self?.finish()
        } textButtonAction: { [weak self] in
            self?.urlOpener.open(url: AppEnvironment.privacyPolicyURL)
        }
        let analyticsPreferenceScreen = GDSScreen(viewModel: viewModel)
        root.isModalInPresentation = true
        root.setViewControllers([analyticsPreferenceScreen], animated: false)
    }
}
