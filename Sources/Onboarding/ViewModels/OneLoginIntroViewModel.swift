import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct OneLoginIntroViewModel: IntroViewModel, BaseViewModel {
    let image: UIImage = UIImage(named: "badge") ?? UIImage()
    // TODO: DCMAW-7083: String keys for localisation needed
    let title: GDSLocalisedString = "app_signInTitle"
    let body: GDSLocalisedString = "app_signInBody"
    let introButtonViewModel: ButtonViewModel
    let analyticsService: AnalyticsService
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: AnalyticsService,
         signinAction: @escaping () -> Void) {
        self.analyticsService = analyticsService
        introButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_signInButton",
                                                        analyticsService: analyticsService) {
            signinAction()
        }
    }
    
    func didAppear() {
        let screen = ScreenView(screen: IntroAnalyticsScreen.welcomeScreen,
                                titleKey: title.stringKey)
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() {
        // Here for BaseViewModel compliance
    }
}
