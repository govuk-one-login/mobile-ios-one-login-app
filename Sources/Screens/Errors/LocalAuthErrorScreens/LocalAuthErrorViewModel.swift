import GDSAnalytics
import GDSCommon
import LocalAuthenticationWrapper
import UIKit

struct LocalAuthErrorViewModel: GDSErrorViewModelV3, BaseViewModel {
    let analyticsService: OneLoginAnalyticsService
    let title: GDSLocalisedString = "app_localAuthManagerErrorTitle"
    let bodyContent: [ScreenBodyItem]
    let buttonViewModels: [ButtonViewModel]
    let image: ErrorScreenImage = .error
    let localAuthType: LocalAuthType
    
    let rightBarButtonTitle: GDSLocalisedString? = "app_cancelButton"
    let backButtonIsHidden: Bool = true

    init(urlOpener: URLOpener = UIApplication.shared,
         analyticsService: OneLoginAnalyticsService,
         localAuthType: LocalAuthType) {
        self.localAuthType = localAuthType
        
        self.analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.onboarding
        ])
        
        self.buttonViewModels = [
            AnalyticsButtonViewModel(titleKey: "app_localAuthManagerErrorGoToSettingsButton",
                                     analyticsService: analyticsService) {
                                         guard let url = URL(string: UIApplication.openSettingsURLString) else {
                                             return
                                         }
                                         urlOpener.open(url: url)
                                     }
        ]
        
        self.bodyContent = [
            BodyTextViewModel(text: GDSLocalisedString("app_localAuthManagerErrorBody1")),
            LocalAuthErrorListView(localAuthType: localAuthType)
        ]
    }
    
    func didAppear() {
        var id: String
        var screen: ErrorAnalyticsScreen
        
        if localAuthType == .faceID {
            id = ErrorAnalyticsScreenID.updateFaceID.rawValue
            screen = ErrorAnalyticsScreen.updateFaceID
        } else {
            id = ErrorAnalyticsScreenID.updateTouchID.rawValue
            screen = ErrorAnalyticsScreen.updateTouchID
        }
        
        let screenView = ErrorScreenView(id: id,
                                         screen: screen,
                                         titleKey: title.stringKey)
        analyticsService.trackScreen(screenView)
    }
    
    func didDismiss() {
        let event = IconEvent(textKey: "back - system")
        analyticsService.logEvent(event)
    }
}
