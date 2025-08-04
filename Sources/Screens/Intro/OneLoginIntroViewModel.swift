import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct OneLoginIntroViewModel: IntroViewModel, BaseViewModel {
    let image: UIImage = UIImage(named: "badge") ?? UIImage()
    let title: GDSLocalisedString = "app_nameString"
    let body: GDSLocalisedString = GDSLocalisedString(stringKey: "app_signInBody",
                                                      "app_nameString")
    let introButtonViewModel: ButtonViewModel
    let analyticsService: OneLoginAnalyticsService
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: OneLoginAnalyticsService,
         signinAction: @escaping () -> Void) {
        self.analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.login,
            OLTaxonomyKey.level3: OLTaxonomyValue.undefined
        ])
        let event = LinkEvent(textKey: "app_extendedSignInButton",
                              variableKeys: "app_nameString",
                              linkDomain: AppEnvironment.mobileBaseURLString,
                              external: .false)
        introButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_extendedSignInButton",
                                                        "app_nameString",
                                                        analyticsService: analyticsService,
                                                        analyticsEvent: event) {
            signinAction()
        }
    }
    
    func didAppear() {
        let screen = ScreenView(id: IntroAnalyticsScreenID.welcome.rawValue,
                                screen: IntroAnalyticsScreen.welcome,
                                titleKey: title.stringKey)
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() { /* Conforming to BaseViewModel */ }
}
