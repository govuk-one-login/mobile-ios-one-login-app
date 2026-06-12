import DesignSystem
import GDSAnalytics
import Logging

struct NetworkConnectionErrorViewModel: GDSCentreAlignedViewModel {
    var screenStyle: GDSScreenStyle
    var body: [any ContentViewModel]
    var movableFooter: [any ContentViewModel]
    var footer: [any ContentViewModel]

    var rightBarButtonTitle: GDSLocalisedString?
    var backButtonTitle: GDSLocalisedString?
    var backButtonIsHidden: Bool

    var didAppear: DesignSystem.Action?
    var didDismiss: DesignSystem.Action?
    
    init(analyticsService: OneLoginAnalyticsService,
         action: @escaping () -> Void) {
        let analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.login,
            OLTaxonomyKey.level3: OLTaxonomyValue.undefined
        ])
        
        self.init(
            screenStyle: .centred,
            body: [
                GDSErrorIconTitleViewModel(
                    icon: .error,
                    errorTitle: GDSTextViewModel(title: GDSLocalisedString(stringKey: "app_networkErrorTitle"),
                                                 titleFont: .largeTitleBold,
                                                 alignment: .center)
                ),
                
                GDSTextViewModel(title: GDSLocalisedString(stringKey: "app_networkErrorBody", "app_nameString"),
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
                let title = GDSLocalisedString(stringKey: "app_networkErrorTitle")
                let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.networkConnection.rawValue,
                                             screen: ErrorAnalyticsScreen.networkConnection,
                                             titleKey: title.stringKey,
                                             reason: "network connection error")
                analyticsService.trackScreen(screen)
            }),
            didDismiss: nil
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
