import GDSAnalytics
import GDSCommon
import Logging

struct SignOutWarningViewModel: GDSCentreAlignedViewModel,
                                GDSCentreAlignedViewModelWithPrimaryButton,
                                BaseViewModel {
    let analyticsService: OneLoginAnalyticsService
    let title: GDSLocalisedString = "app_signOutWarningTitle"
    let body: GDSLocalisedString? = GDSLocalisedString(stringKey: "app_signOutWarningBody",
                                                       "app_nameString")
    let primaryButtonViewModel: ButtonViewModel
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: OneLoginAnalyticsService,
         action: @escaping () -> Void) {
        self.analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.login,
            OLTaxonomyKey.level3: OLTaxonomyValue.undefined
        ])
        let event = LinkEvent(textKey: "app_extendedSignInButton",
                              variableKeys: "app_nameString",
                              linkDomain: AppEnvironment.mobileBaseURLString,
                              external: .false)
        self.primaryButtonViewModel = AnalyticsButtonViewModel(
            titleKey: "app_extendedSignInButton",
            "app_nameString",
            shouldLoadOnTap: true,
            analyticsService: analyticsService,
            analyticsEvent: event
        ) {
            action()
        }
    }
    
    func didAppear() {
        let screen = ScreenView(id: ErrorAnalyticsScreenID.signOutWarning.rawValue,
                                screen: ErrorAnalyticsScreen.signOutWarning,
                                titleKey: title.stringKey)
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() { /* BaseViewModel compliance */ }
}
