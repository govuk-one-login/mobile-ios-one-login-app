import DesignSystem
import GDSAnalytics
import Logging
import UIKit

struct ProveIdentityGuidanceViewModel: GDSLeftAlignedViewModel {
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
         urlOpener: URLOpener = UIApplication.shared) {
        let analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.home,
            OLTaxonomyKey.level3: OLTaxonomyValue.undefined
        ])
        
        self.init(
            screenStyle: .top,
            body: [
                GDSTextViewModel(title: "app_proveYourIdentityGuidanceTitle",
                                 titleFont: .largeTitleBold,
                                 verticalPadding: .bottom(DesignSystem.Spacing.default)),
                GDSTextViewModel(title: "app_proveYourIdentityGuidanceBody1",
                                 verticalPadding: .bottom(DesignSystem.Spacing.default)),
                GDSButtonViewModel(title: GDSLocalisedString(stringKey: "app_proveYourIdentityGuidanceLink").value,
                                   icon: .arrowUpRight,
                                   style: .secondary.adjusting(alignment: .leading),
                                   buttonAction: .action({
                                       let event = LinkEvent(textKey: "app_proveYourIdentityGuidanceLink",
                                                             linkDomain: AppEnvironment.govSignInURL.absoluteString,
                                                             external: .true)
                                       analyticsService.logEvent(event)
                                       
                                       urlOpener.open(url: AppEnvironment.govSignInURL)
                                   }),
                                   verticalPadding: .bottom(DesignSystem.Spacing.default)),
                GDSTextViewModel(title: GDSLocalisedString(stringLiteral: "app_proveYourIdentityGuidanceBody2",
                                                           stringAttributes: [(GDSLocalisedString("app_proveYourIdentityGuidanceBody2").value, [.font: UIFont.bodyBold])]),
                                 verticalPadding: .bottom(DesignSystem.Spacing.default)),
                GDSTextViewModel(title: "app_proveYourIdentityGuidanceBody3",
                                 verticalPadding: .bottom(DesignSystem.Spacing.default))
            ],
            movableFooter: [],
            footer: [],
            rightBarButtonTitle: "app_doneButton",
            backButtonTitle: nil,
            backButtonIsHidden: true,
            didAppear: .action({
                let screen = ScreenView(id: HomeAnalyticsScreenID.proveIdentityGuidance.rawValue,
                                        screen: HomeAnalyticsScreen.proveIdentityGuidance,
                                        titleKey: "app_proveYourIdentityGuidanceTitle")
                analyticsService.trackScreen(screen)
            }),
            didDismiss: .action({
                let event = ButtonEvent(textKey: "app_doneButton")
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
