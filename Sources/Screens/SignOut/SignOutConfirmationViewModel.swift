import DesignSystem
import GDSAnalytics
import Logging

struct SignOutConfirmationViewModel: GDSLeftAlignedViewModel {
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
            OLTaxonomyKey.level2: OLTaxonomyValue.settings,
            OLTaxonomyKey.level3: OLTaxonomyValue.signout
        ])
        self.init(
            body: [
                GDSTextViewModel(title: "app_signOutConfirmationTitle",
                                 titleFont: .largeTitleBold,
                                 accessibilityTraits: .header),
                
                GDSTextViewModel(title: "app_signOutConfirmationBody1"),
                
                GDSListViewModel(title: "app_signOutConfirmationBody2",
                                 items: ["app_signOutConfirmationBullet1",
                                         "app_signOutConfirmationBullet2",
                                         "app_signOutConfirmationBullet3"],
                                 style: .bulleted),
                
                GDSTextViewModel(title: "app_signOutConfirmationBody3")
            ],
            movableFooter: [
                GDSButtonViewModel(title: GDSLocalisedString(stringKey: "app_signOutAndDeleteAppDataButton").value,
                                   style: .destructive,
                                   buttonAction: .action({
                                       let event = ButtonEvent(textKey: "app_signOutAndDeleteAppDataButton")
                                       analyticsService.logEvent(event)
                                       
                                       action()
                                   }),
                                   verticalPadding: .bottom(DesignSystem.Spacing.default),
                                   horizontalPadding: .horizontal(DesignSystem.Spacing.default))
            ],
            footer: [],
            rightBarButtonTitle: "app_cancelButton",
            backButtonTitle: nil,
            backButtonIsHidden: true,
            didAppear: .action({
                let screen = ScreenView(id: SettingsAnalyticsScreenID.signOutScreen.rawValue,
                                        screen: SettingsAnalyticsScreen.signOutScreen,
                                        titleKey: "app_signOutErrorTitle")
                analyticsService.trackScreen(screen)
            }),
            didDismiss: .action({
                let event = ButtonEvent(textKey: "app_cancelButton")
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
