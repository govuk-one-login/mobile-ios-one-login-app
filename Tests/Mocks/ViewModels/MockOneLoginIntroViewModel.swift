import GDSAnalytics
import GDSCommon
import Logging
@testable import OneLogin
import UIKit

struct MockOneLoginIntroViewModel: IntroViewModel {
    var image: UIImage = UIImage(named: "badge") ?? UIImage()
    var title: GDSLocalisedString = "GOV.UK One Login"
    var body: GDSLocalisedString = "Sign in with the email address you use for your GOV.UK One Login."
    var introButtonViewModel: ButtonViewModel
    let analyticsService: AnalyticsService
    
    init(analyticsService: AnalyticsService,
         signinAction: @escaping () -> Void) {
        self.analyticsService = analyticsService
        introButtonViewModel = AnalyticsButtonViewModel(titleKey: "Sign in",
                                                        analyticsService: analyticsService) {
            signinAction()
        }
    }
    
    func didAppear() {
        let screen = ScreenView(screen: IntroAnalyticsScreen.welcomeScreen,
                                titleKey: title.stringKey)
        analyticsService.trackScreen(screen)
    }
}
