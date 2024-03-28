import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct OneLoginIntroViewModel: IntroViewModel, BaseViewModel {
    let image: UIImage = UIImage(named: "badge") ?? UIImage()
    let title: GDSLocalisedString = "app_signInTitle"
    let body: GDSLocalisedString = "app_signInBody"
    let introButtonViewModel: ButtonViewModel
    let analyticsService: AnalyticsService
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: AnalyticsService,
         signinAction: @escaping () -> Void) {
        self.analyticsService = analyticsService
        let event = LinkEvent(textKey: "app_signInButton",
                              linkDomain: AppEnvironment.oneLoginBaseURL,
                              external: .true)
        introButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_signInButton",
                                                        analyticsService: analyticsService,
                                                        analyticsEvent: event) {
            signinAction()
        }
    }
    
    func didAppear() {
        let screen = ScreenView(id: IntroAnalyticsScreenID.welcomeScreen.rawValue,
                                screen: IntroAnalyticsScreen.welcomeScreen,
                                titleKey: title.stringKey)
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() {
        // Here for BaseViewModel compliance
    }
}
