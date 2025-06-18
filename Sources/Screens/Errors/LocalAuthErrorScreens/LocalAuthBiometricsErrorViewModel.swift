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
    let dismissAction: (() -> Void)?
    
    let localAuthType: LocalAuthType
    let biometricsTypeString: String
    let rightBarButtonTitle: GDSLocalisedString? = "app_cancelButton"
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: OneLoginAnalyticsService,
         localAuthType: LocalAuthType,
         action: @escaping () -> Void,
         dismissAction: (() -> Void)? = nil) {
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
        self.dismissAction = dismissAction
    }
    
    func didAppear() {
        let id: String
        let screen: ErrorAnalyticsScreen
        
        if localAuthType == .faceID {
            id = ErrorAnalyticsScreenID.allowFaceID.rawValue
            screen = ErrorAnalyticsScreen.allowFaceID
        } else {
            id = ErrorAnalyticsScreenID.allowTouchID.rawValue
            screen = ErrorAnalyticsScreen.allowTouchID
        }
        
        let screenView = ErrorScreenView(id: id,
                                         screen: screen,
                                         titleKey: title.stringKey)
        analyticsService.trackScreen(screenView)
    }
    
    func didDismiss() {
        dismissAction?()
        let event = IconEvent(textKey: "back - system")
        analyticsService.logEvent(event)
    }
}
