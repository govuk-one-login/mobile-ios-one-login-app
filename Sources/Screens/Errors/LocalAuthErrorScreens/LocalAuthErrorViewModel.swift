import GDSCommon
import UIKit

struct LocalAuthErrorViewModel: GDSErrorViewModelV3, BaseViewModel {
    let analyticsService: OneLoginAnalyticsService
    var title: GDSLocalisedString = "app_localAuthManagerErrorTitle"
    var bodyContent: [ScreenBodyItem]
    var buttonViewModels: [ButtonViewModel]
    var image: ErrorScreenImage = .error
    
    let rightBarButtonTitle: GDSLocalisedString? = "app_cancelButton"
    var backButtonIsHidden: Bool = true

    init(urlOpener: URLOpener = UIApplication.shared,
         analyticsService: OneLoginAnalyticsService) {
        self.analyticsService = analyticsService
        
        self.buttonViewModels = [
            AnalyticsButtonViewModel(titleKey: "app_localAuthManagerErrorGoToSettingsButton",
                                     analyticsService: analyticsService) {
            guard let url = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            urlOpener.open(url: url)
        }]
        
        self.bodyContent = [
            BodyTextViewModel(text: GDSLocalisedString("app_localAuthManagerErrorBody1")),
            NumberedListView()
        ]
    }
    
    func didAppear() { }

    func didDismiss() { }
}
