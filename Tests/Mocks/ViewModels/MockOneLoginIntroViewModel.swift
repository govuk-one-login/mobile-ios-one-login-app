import GDSAnalytics
import GDSCommon
import Logging
@testable import OneLogin
import UIKit

struct MockOneLoginIntroViewModel: IntroViewModel {
    let image: UIImage = UIImage()
    let title: GDSLocalisedString = "testTitle"
    let body: GDSLocalisedString = "testBody"
    let introButtonViewModel: ButtonViewModel
    let analyticsService: AnalyticsService
    
    init(analyticsService: AnalyticsService,
         signinAction: @escaping () -> Void) {
        self.analyticsService = analyticsService
        introButtonViewModel = AnalyticsButtonViewModel(titleKey: "testButton",
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