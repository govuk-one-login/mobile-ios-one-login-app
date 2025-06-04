import GDSAnalytics
import GDSCommon
import Logging

struct NetworkConnectionErrorViewModel: GDSErrorViewModelV3,
                                        BaseViewModel {
    let analyticsService: OneLoginAnalyticsService
    let title: GDSLocalisedString = "app_networkErrorTitle"
    let bodyContent: [ScreenBodyItem] = [BodyTextViewModel(text: GDSLocalisedString(stringKey: "app_networkErrorBody",
                                                                                    "app_nameString"))]
    let buttonViewModels: [ButtonViewModel]
    let image: ErrorScreenImage = .error
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: OneLoginAnalyticsService, action: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.buttonViewModels = [
            AnalyticsButtonViewModel(titleKey: "app_tryAgainButton",
                                     analyticsService: analyticsService) {
                                         action()
                                     }
        ]
    }
    
    func didAppear() {
        let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.networkConnection.rawValue,
                                     screen: ErrorAnalyticsScreen.networkConnection,
                                     titleKey: title.stringKey,
                                     reason: "network connection error")
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() { /* BaseViewModel compliance */ }
}
