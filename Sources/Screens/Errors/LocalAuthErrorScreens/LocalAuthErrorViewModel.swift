import GDSCommon
import LocalAuthenticationWrapper
import UIKit

struct LocalAuthErrorViewModel: GDSErrorViewModelV3, BaseViewModel {
    let analyticsService: OneLoginAnalyticsService
    let title: GDSLocalisedString = "app_localAuthManagerErrorTitle"
    let bodyContent: [ScreenBodyItem]
    let buttonViewModels: [ButtonViewModel]
    let image: ErrorScreenImage = .error
    
    let rightBarButtonTitle: GDSLocalisedString? = "app_cancelButton"
    let backButtonIsHidden: Bool = true

    init(urlOpener: URLOpener = UIApplication.shared,
         analyticsService: OneLoginAnalyticsService,
         localAuthType: LocalAuthType) {
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
            LocalAuthErrorBulletView(localAuthType: localAuthType)
        ]
    }
    
    func didAppear() { /* BaseViewModel compliance */ }

    func didDismiss() { /* BaseViewModel compliance */ }
}
