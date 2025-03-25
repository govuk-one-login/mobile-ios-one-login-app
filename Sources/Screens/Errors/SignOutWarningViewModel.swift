import GDSAnalytics
import GDSCommon
import Logging

struct SignOutWarningViewModel: GDSErrorViewModelV2,
                                BaseViewModel {
    let title: GDSLocalisedString = "app_signOutWarningTitle"
    let body: GDSLocalisedString = "app_signOutWarningBody"
    let primaryButtonViewModel: ButtonViewModel
    let secondaryButtonViewModel: ButtonViewModel? = nil
    let analyticsService: OneLoginAnalyticsService

    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: OneLoginAnalyticsService,
         action: @escaping () -> Void) {
        self.analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.login,
            OLTaxonomyKey.level3: OLTaxonomyValue.reauth
        ])
        let event = LinkEvent(textKey: "app_extendedSignInButton",
                              linkDomain: AppEnvironment.mobileBaseURLString,
                              external: .false)
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_extendedSignInButton",
                                                               analyticsService: analyticsService,
                                                               analyticsEvent: event) {
            action()
        }
    }
    
    func didAppear() {
        let screen = ScreenView(id: ErrorAnalyticsScreen.signOutWarning.rawValue,
                                screen: ErrorAnalyticsScreen.signOutWarning,
                                titleKey: title.stringKey)
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() { /* BaseViewModel compliance */ }
}
