import DesignSystem
import GDSAnalytics
import LocalAuthenticationWrapper
import Logging

struct LocalAuthBiometricsErrorViewModel: GDSCentreAlignedViewModel {
    var screenStyle: GDSScreenStyle
    var body: [any ContentViewModel]
    var movableFooter: [any ContentViewModel]
    var footer: [any ContentViewModel]

    var rightBarButtonTitle: GDSLocalisedString?
    var backButtonTitle: GDSLocalisedString?
    var backButtonIsHidden: Bool

    var didAppear: DesignSystem.Action?
    var didDismiss: DesignSystem.Action?
    
    // swiftlint: disable:next function_body_length
    init(analyticsService: OneLoginAnalyticsService,
         localAuthType: LocalAuthType,
         action: @escaping () async -> Void,
         dismissAction: (() -> Void)? = nil) {
        let analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.localAuth,
            OLTaxonomyKey.level3: OLTaxonomyValue.undefined
        ])
        
        let biometricsTypeString = localAuthType == .faceID ? "app_FaceID" : "app_TouchID"
        let title = GDSLocalisedString(stringKey: "app_localAuthManagerBiometricsErrorTitle", biometricsTypeString)
        let bodyContent = localAuthType == .faceID ? "app_localAuthManagerBiometricsFaceIDErrorBody" : "app_localAuthManagerBiometricsTouchIDErrorBody"
        
        self.init(
            screenStyle: .centred,
            body: [
                GDSErrorIconTitleViewModel(
                    icon: .error,
                    errorTitle: GDSTextViewModel(title: title,
                                                 titleFont: .largeTitleBold,
                                                 alignment: .center)
                ),
                GDSTextViewModel(title: GDSLocalisedString(stringKey: bodyContent),
                                 alignment: .center,
                                 verticalPadding: .bottom(DesignSystem.Spacing.default))
            ],
            movableFooter: [
                GDSButtonViewModel(title: GDSLocalisedString(stringKey: "app_enableBiometricsTitle",
                                                             biometricsTypeString).value,
                                   style: .primary,
                                   buttonAction: .asyncAction({
                                      let event = ButtonEvent(textKey: "app_enableBiometricsTitle",
                                                              variableKeys: [biometricsTypeString])
                                       analyticsService.logEvent(event)
                                       
                                       await action()
                                   }),
                                   verticalPadding: .bottom(DesignSystem.Spacing.default),
                                   horizontalPadding: .horizontal(DesignSystem.Spacing.default))
            ],
            footer: [],
            rightBarButtonTitle: "app_cancelButton",
            backButtonTitle: nil,
            backButtonIsHidden: true,
            didAppear: .action({
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
                                                 titleKey: title.stringKey,
                                                 variableKeys: [biometricsTypeString])
                analyticsService.trackScreen(screenView)
            }),
            didDismiss: .action({
                dismissAction?()
                let event = IconEvent(textKey: "cancel")
                analyticsService.logEvent(event)
            })
        )
    }
    
    init(screenStyle: GDSScreenStyle,
         body: [any ContentViewModel],
         movableFooter: [any ContentViewModel],
         footer: [any ContentViewModel],
         rightBarButtonTitle: GDSLocalisedString?,
         backButtonTitle: GDSLocalisedString?,
         backButtonIsHidden: Bool,
         didAppear: DesignSystem.Action?,
         didDismiss: DesignSystem.Action?) {
        self.screenStyle = screenStyle
        self.body = body
        self.movableFooter = movableFooter
        self.footer = footer
        self.rightBarButtonTitle = rightBarButtonTitle
        self.backButtonTitle = backButtonTitle
        self.backButtonIsHidden = backButtonIsHidden
        self.didAppear = didAppear
        self.didDismiss = didDismiss
    }
}
