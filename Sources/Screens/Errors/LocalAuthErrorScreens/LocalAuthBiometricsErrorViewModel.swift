import GDSAnalytics
import GDSCommon
import LocalAuthenticationWrapper
import Logging

struct LocalAuthBiometricsErrorViewModel: GDSErrorViewModelV3, BaseViewModel {
    let analyticsService: OneLoginAnalyticsService
    let title: GDSLocalisedString
    let bodyContent: [ScreenBodyItem]
    let buttonViewModels: [ButtonViewModel]
    let image: ErrorScreenImage = .error
    
    let localAuthType: LocalAuthType
    let biometricsTypeString: String
    let rightBarButtonTitle: GDSLocalisedString? = "app_cancelButton"
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: OneLoginAnalyticsService,
         localAuthType: LocalAuthType,
         action: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.localAuthType = localAuthType
        self.biometricsTypeString = localAuthType == .faceID ? "app_FaceID" : "app_TouchID"
        self.title = GDSLocalisedString(stringKey: "app_localAuthManagerBiometricsErrorTitle", biometricsTypeString)
        self.bodyContent = [BodyTextViewModel(text: localAuthType == .faceID ?
                                              "app_localAuthManagerBiometricsFaceIDErrorBody" :
                                                "app_localAuthManagerBiometricsTouchIDErrorBody")]
        
        self.buttonViewModels = [
            AnalyticsButtonViewModel(titleKey: "app_enableBiometricsTitle",
                                     biometricsTypeString,
                                     analyticsService: analyticsService) {
                                         action()
                                     }
        ]
    }
    
    func didAppear() {
        // TODO: DCMAW-12769 Implement analytics
    }
    
    func didDismiss() { /* BaseViewModel compliance */ }
}
