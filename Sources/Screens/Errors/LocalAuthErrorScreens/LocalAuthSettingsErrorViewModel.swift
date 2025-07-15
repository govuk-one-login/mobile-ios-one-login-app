import GDSAnalytics
import GDSCommon
import LocalAuthenticationWrapper
import UIKit

struct LocalAuthSettingsErrorViewModel: GDSErrorViewModelV3, BaseViewModel {
    let analyticsService: OneLoginAnalyticsService
    let title: GDSLocalisedString = "app_localAuthManagerErrorTitle"
    let bodyContent: [ScreenBodyItem]
    let buttonViewModels: [ButtonViewModel]
    let image: ErrorScreenImage = .error
    let localAuthType: LocalAuthType
    let completion: (() -> Void)?
    
    let rightBarButtonTitle: GDSLocalisedString? = "app_cancelButton"
    let backButtonIsHidden: Bool = true

    init(urlOpener: URLOpener = UIApplication.shared,
         analyticsService: OneLoginAnalyticsService,
         localAuthType: LocalAuthType,
         completion: (() -> Void)? = nil) {
        self.localAuthType = localAuthType
        self.completion = completion
        
        self.analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.onboarding
        ])
        
        self.buttonViewModels = [
            AnalyticsButtonViewModel(titleKey: "app_localAuthManagerErrorGoToSettingsButton",
                                     analyticsService: analyticsService) {
                                         guard let url = URL(string: "App-Prefs:PASSCODE") else {
                                             return
                                         }
                                         urlOpener.open(url: url)
                                         completion?()
                                     }
        ]
        
        self.bodyContent = [
            BodyTextViewModel(text: "app_localAuthManagerErrorBody1"),
            LocalAuthErrorListView(localAuthType: localAuthType)
        ]
    }
    
    func didAppear() {
        let id: String
        let screen: ErrorAnalyticsScreen
        
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
        completion?()
        let event = IconEvent(textKey: "back - system")
        analyticsService.logEvent(event)
    }
}
