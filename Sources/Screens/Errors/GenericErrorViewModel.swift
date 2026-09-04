import DesignSystem
import GDSAnalytics
import Logging

struct GenericErrorViewModel: GDSCentreAlignedViewModel {
    var screenStyle: GDSScreenStyle
    var body: [any ContentViewModel]
    var movableFooter: [any ContentViewModel]
    var footer: [any ContentViewModel]

    var rightBarButtonTitle: GDSLocalisedString?
    var backButtonTitle: GDSLocalisedString?
    var backButtonIsHidden: Bool

    var didAppear: DesignSystem.Action?
    var didDismiss: DesignSystem.Action?
    
    var errorDescription: String?
    
    init(analyticsService: OneLoginAnalyticsService,
         errorDescription: String,
         action: @escaping () -> Void) {
        let analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.system,
            OLTaxonomyKey.level3: OLTaxonomyValue.undefined
        ])
        
        self.init(
            screenStyle: .centred,
            body: [
                GDSErrorIconTitleViewModel(
                    icon: .error,
                    errorTitle: GDSTextViewModel(title: "app_genericErrorPage",
                                                 titleFont: .largeTitleBold,
                                                 alignment: .center,
                                                 accessibilityTraits: .header)
                ),
                
                GDSTextViewModel(title: "app_genericErrorPageBody",
                                 alignment: .center,
                                 verticalPadding: .top(0))
            ],
            movableFooter: [
                GDSButtonViewModel(title: GDSLocalisedString(stringKey: "app_tryAgainButton").value,
                                   style: .primary,
                                   buttonAction: .action({
                                       let event = ButtonEvent(textKey: "app_tryAgainButton")
                                       analyticsService.logEvent(event)
                                       
                                       action()
                                   }),
                                   verticalPadding: .bottom(DesignSystem.Spacing.default),
                                   horizontalPadding: .horizontal(DesignSystem.Spacing.default))
            ],
            footer: [],
            rightBarButtonTitle: nil,
            backButtonTitle: nil,
            backButtonIsHidden: true,
            didAppear: .action({
                let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.generic.rawValue,
                                             screen: ErrorAnalyticsScreen.generic,
                                             titleKey: "app_genericErrorPage",
                                             reason: errorDescription)
                analyticsService.trackScreen(screen)
            }),
            didDismiss: nil
        )
        self.errorDescription = errorDescription
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
