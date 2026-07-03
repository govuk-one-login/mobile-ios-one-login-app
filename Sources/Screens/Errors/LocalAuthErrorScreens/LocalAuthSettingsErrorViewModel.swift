import DesignSystem
import GDSAnalytics
import LocalAuthenticationWrapper
import UIKit

struct LocalAuthSettingsErrorViewModel: GDSLeftAlignedViewModel {
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
         completion: (() -> Void)? = nil) {
        let analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.localAuth,
            OLTaxonomyKey.level3: OLTaxonomyValue.undefined
        ])
        
        let listText = localAuthType == .faceID ?
        GDSLocalisedString(stringLiteral: "app_localAuthManagerErrorNumberedList1FaceID",
                           stringAttributes: [("Face ID & Passcode", [.font: UIFont.bodyBold])]) :
        GDSLocalisedString(stringLiteral: "app_localAuthManagerErrorNumberedList1TouchID",
                           stringAttributes: [("Touch ID & Passcode", [.font: UIFont.bodyBold])])
        self.init(
            screenStyle: .centred,
            body: [
                GDSErrorIconTitleViewModel(
                    icon: .error,
                    errorTitle: GDSTextViewModel(title: GDSLocalisedString(stringKey: "app_localAuthManagerErrorTitle"),
                                                 titleFont: .largeTitleBold,
                                                 alignment: .center)
                ),
                GDSTextViewModel(title: GDSLocalisedString(stringKey: "app_localAuthManagerErrorBody1"),
                                 alignment: .center,
                                 verticalPadding: .bottom(DesignSystem.Spacing.default)),
                GDSListViewModel(
                    title: GDSLocalisedString(stringKey: "app_localAuthManagerErrorBody3"),
                    titleConfig: (font: .body, isHeader: true),
                    items: [
                        GDSLocalisedString(stringKey: "app_localAuthManagerErrorNumberedList0"),
                        listText,
                        GDSLocalisedString(stringLiteral: "app_localAuthManagerErrorNumberedList2",
                                           stringAttributes: [("Turn Passcode On", [.font: UIFont.bodyBold])]),
                        GDSLocalisedString(stringKey: "app_localAuthManagerErrorNumberedList3")
                    ],
                    style: .numbered,
                    verticalPadding: .bottom(DesignSystem.Spacing.default)
                )
            ],
            movableFooter: [],
            footer: [],
            rightBarButtonTitle: "app_cancelButton",
            backButtonTitle: nil,
            backButtonIsHidden: true,
            didAppear: .action({
                let id: String
                let screen: ErrorAnalyticsScreen
                
                if localAuthType == .faceID {
                    id = ErrorAnalyticsScreenID.updateFaceID.rawValue
                    screen = ErrorAnalyticsScreen.updateFaceID
                } else {
                    id = ErrorAnalyticsScreenID.updateTouchID.rawValue
                    screen = ErrorAnalyticsScreen.updateTouchID
                }
                let title = GDSLocalisedString(stringKey: "app_localAuthManagerErrorTitle")
                let screenView = ErrorScreenView(id: id,
                                                 screen: screen,
                                                 titleKey: title.stringKey)
                analyticsService.trackScreen(screenView)
            }),
            didDismiss: .action({
                completion?()
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
