import GDSAnalytics
import GDSCommon
import Logging
@testable import OneLogin
import UIKit

struct MockOneLoginIntroViewModel: IntroViewModel, BaseViewModel {
    let image: UIImage = UIImage()
    let title: GDSLocalisedString = "testTitle"
    let body: GDSLocalisedString = "testBody"
    let introButtonViewModel: ButtonViewModel
    let analyticsService: AnalyticsService
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
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
    
    func didDismiss() { }
}
