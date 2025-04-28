import GDSCommon
import UIKit

struct LocalAuthErrorViewModel: GDSErrorViewModelV3, BaseViewModel {
    let analyticsService: OneLoginAnalyticsService
    let title: GDSLocalisedString = "app_localAuthManagerErrorTitle"
    let bodyContent: [ScreenBodyItem] = [
        BodyTextViewModel(text: GDSLocalisedString("app_localAuthManagerErrorBody1")),
        LocalAuthErrorBulletView()
    ]
    let buttonViewModels: [ButtonViewModel]
    let image: ErrorScreenImage = .error
    
    let rightBarButtonTitle: GDSLocalisedString? = "app_cancelButton"
    let backButtonIsHidden: Bool = true

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
    }
    
    func didAppear() { /* BaseViewModel compliance */ }

    func didDismiss() { /* BaseViewModel compliance */ }
}
