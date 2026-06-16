import DesignSystem
import GDSAnalytics
import Logging

struct SignOutErrorViewModel: GDSCentreAlignedViewModel {
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
         error: Error,
         action: @escaping () -> Void) {
        self.init(
            screenStyle: .centred,
            body: [
                GDSErrorIconTitleViewModel(
                    icon: .error,
                    errorTitle: GDSTextViewModel(title: GDSLocalisedString(stringKey: "app_signOutErrorTitle"),
                                                 titleFont: .largeTitleBold,
                                                 alignment: .center)
                ),
                
                GDSTextViewModel(title: GDSLocalisedString(stringKey: "app_signOutErrorBody"),
                                 alignment: .center,
                                 verticalPadding: .top(0))
            ],
            movableFooter: [
                GDSButtonViewModel(title: GDSLocalisedString(stringKey: "app_signOutErrorButton").value,
                                   style: .primary,
                                   buttonAction: .action({
                                       let event = ButtonEvent(textKey: "app_signOutErrorButton")
                                       analyticsService.logEvent(event)
                                       
                                       action()
                                   }),
                                   accessibilityIdentifier: "error-screen-button-0",
                                   verticalPadding: .bottom(DesignSystem.Spacing.default),
                                   horizontalPadding: .horizontal(DesignSystem.Spacing.default))
            ],
            footer: [],
            rightBarButtonTitle: nil,
            backButtonTitle: nil,
            backButtonIsHidden: true,
            didAppear: .action({
                analyticsService.logCrash(error)
                
                let title = GDSLocalisedString(stringKey: "app_signOutErrorTitle")
                let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.signOut.rawValue,
                                             screen: ErrorAnalyticsScreen.signOut,
                                             titleKey: title.stringKey,
                                             reason: error.localizedDescription)
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
