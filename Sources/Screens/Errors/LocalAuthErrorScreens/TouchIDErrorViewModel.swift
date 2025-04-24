import GDSCommon
import UIKit

struct TouchIDErrorViewModel: GDSErrorViewModelV3, BaseViewModel {
    let analyticsService: OneLoginAnalyticsService
    var title: GDSLocalisedString = "app_localAuthManagerErrorTitle"
    var bodyContent: [ScreenBodyItem]
    var buttonViewModels: [ButtonViewModel]
    var image: ErrorScreenImage = .error
    
    let rightBarButtonTitle: GDSLocalisedString? = "app_cancelButton"
    var backButtonIsHidden: Bool = true

    init(analyticsService: OneLoginAnalyticsService,
         action: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.buttonViewModels = [AnalyticsButtonViewModel(titleKey: "app_localAuthManagerErrorGoToSettingsButton",
                                                          analyticsService: analyticsService) {
            action()
        }]
        
        let bodyParagraph = BodyTextViewModel(text: GDSLocalisedString("app_localAuthManagerErrorBody1"))
        self.bodyContent = [
            bodyParagraph,
            ScreenBody()
        ]
    }
    
    func didAppear() { }
    
    func didDismiss() { }
}
