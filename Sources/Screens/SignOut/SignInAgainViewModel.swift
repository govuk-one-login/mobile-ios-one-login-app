import DesignSystem
import GDSAnalytics
import Logging

struct SignInAgainViewModel: GDSCentreAlignedViewModel {
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
         action: @escaping () -> Task<Void, Never>?) {
        let analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.login,
            OLTaxonomyKey.level3: OLTaxonomyValue.undefined
        ])
        
        self.init(
            screenStyle: .centred,
            body: [
                GDSTextViewModel(title: "app_signInAgainTitle",
                                 titleFont: .largeTitleBold,
                                 alignment: .center,
                                 accessibilityTraits: .header),
                
                GDSTextViewModel(title: GDSLocalisedString(stringKey: "app_signInAgainBody", "app_nameString"),
                                 alignment: .center)
            ],
            movableFooter: [
                GDSButtonViewModel(title: GDSLocalisedString(stringKey: "app_extendedSignInButton", "app_nameString").value,
                                   style: .primary,
                                   buttonAction: .asyncAction({
                                       let event = LinkEvent(textKey: "app_extendedSignInButton",
                                                                    variableKeys: "app_nameString",
                                                                    linkDomain: AppEnvironment.mobileBaseURLString,
                                                                    external: .false)
                                       analyticsService.logEvent(event)
                                       
                                       let task = action()
                                       await task?.value
                                   }),
                                   verticalPadding: .bottom(DesignSystem.Spacing.default),
                                   horizontalPadding: .horizontal(DesignSystem.Spacing.default))
            ],
            footer: [],
            rightBarButtonTitle: nil,
            backButtonTitle: nil,
            backButtonIsHidden: true,
            didAppear: .action({
                let screen = ScreenView(id: IntroAnalyticsScreenID.signInAgain.rawValue,
                                        screen: IntroAnalyticsScreen.signInAgain,
                                        titleKey: "app_signInAgainTitle")
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
