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
        introButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_signInButton",
                                                        analyticsService: analyticsService) {
            signinAction()
        }
    }
    
    func didAppear() {
        let screen = ScreenView(id: "30a6b339-75a8-44a2-a79a-e108546419bf",
                                screen: IntroAnalyticsScreen.welcomeScreen,
                                titleKey: title.stringKey)
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() {
        // Here for BaseViewModel compliance
    }
}
