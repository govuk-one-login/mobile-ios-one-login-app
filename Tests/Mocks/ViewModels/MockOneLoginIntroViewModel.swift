import GDSAnalytics
import GDSCommon
import Logging
@testable import OneLogin
import UIKit

struct MockOneLoginIntroViewModel: IntroViewModel {
    var image: UIImage = UIImage()
    var title: GDSLocalisedString = "testTitle"
    var body: GDSLocalisedString = "testBody"
    var introButtonViewModel: ButtonViewModel
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
