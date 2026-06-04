import DesignSystem
import GDSAnalytics
import Logging
import UIKit

struct OneLoginIntroViewModel: GDSCentreAlignedViewModel {
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
         signinAction: @escaping () -> Void) {
        let analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.login,
            OLTaxonomyKey.level3: OLTaxonomyValue.undefined
        ])
        
        self.init(
            screenStyle: .centred,
            body: [
                GDSImageViewModel(image: UIImage(named: "badge") ?? UIImage(),
                                  imageHeightConstraint: 137,
                                  verticalPadding: .bottom(16)),
                GDSTextViewModel(title: "app_nameString",
                                 titleFont: .largeTitleBold,
                                 alignment: .center,
                                 verticalPadding: .bottom(16)),
                GDSTextViewModel(title: GDSLocalisedString(stringKey: "app_signInBody", "app_nameString"),
                                 alignment: .center,
                                 verticalPadding: .top(0))
            ],
            movableFooter: [
                GDSButtonViewModel(title: GDSLocalisedString(stringKey: "app_extendedSignInButton", "app_nameString").value,
                                   style: .primary,
                                   buttonAction: .action({
                                       signinAction()
                                       
                                       let event = LinkEvent(textKey: "app_extendedSignInButton",
                                                             variableKeys: "app_nameString",
                                                             linkDomain: AppEnvironment.mobileBaseURLString,
                                                             external: .false)
                                       analyticsService.logEvent(event)
                                   }),
                                   verticalPadding: .bottom(16),
                                   horizontalPadding: .horizontal(16))
            ],
            footer: [],
            rightBarButtonTitle: nil,
            backButtonTitle: nil,
            backButtonIsHidden: true,
            didAppear: .action({
                let title = GDSLocalisedString(stringKey: "app_nameString")
                let screen = ScreenView(id: IntroAnalyticsScreenID.welcome.rawValue,
                                        screen: IntroAnalyticsScreen.welcome,
                                        titleKey: title.stringKey)
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
