import DesignSystem
import Logging
import UIKit

struct AnalyticsPreferenceViewModel: GDSLeftAlignedViewModel {
    var screenStyle: GDSScreenStyle
    var body: [any ContentViewModel]
    var movableFooter: [any ContentViewModel]
    var footer: [any ContentViewModel]

    var rightBarButtonTitle: GDSLocalisedString?
    var backButtonTitle: GDSLocalisedString?
    var backButtonIsHidden: Bool

    var didAppear: DesignSystem.Action?
    var didDismiss: DesignSystem.Action?

    init(primaryButtonAction: @escaping () -> Void,
         secondaryButtonAction: @escaping () -> Void,
         textButtonAction: @escaping () -> Void) {
        self.init(
            screenStyle: .top,
            body: [
                GDSTextViewModel(title: "app_acceptAnalyticsPreferences_title",
                                 titleFont: .largeTitleBold,
                                 alignment: .left,
                                 verticalPadding: .bottom(DesignSystem.Spacing.default)),
                GDSTextViewModel(title: GDSLocalisedString(stringKey: "acceptAnalyticsPreferences_body",
                                                           "app_nameString"),
                                 alignment: .left,
                                 verticalPadding: .bottom(DesignSystem.Spacing.default)),
                GDSButtonViewModel(title: GDSLocalisedString(stringKey: "app_privacyNoticeLink", "app_nameString").value,
                                   style: .secondaryLeading,
                                   buttonAction: .action({
                                       textButtonAction()
                                   }),
                                   accessibilityHint: GDSLocalisedString("app_externalBrowser").value,
                                   verticalPadding: .bottom(DesignSystem.Spacing.default),
                                   horizontalPadding: .horizontal(DesignSystem.Spacing.default))
            ],
            movableFooter: [
                GDSButtonViewModel(title: GDSLocalisedString(stringKey: "app_shareAnalyticsButton").value,
                                   style: .primary,
                                   buttonAction: .action({
                                       primaryButtonAction()
                                   }),
                                   verticalPadding: .bottom(DesignSystem.Spacing.default),
                                   horizontalPadding: .horizontal(DesignSystem.Spacing.default)),
                GDSButtonViewModel(title: GDSLocalisedString(stringKey: "app_doNotShareAnalytics").value,
                                   style: .secondary,
                                   buttonAction: .action({
                                       secondaryButtonAction()
                                   }),
                                   verticalPadding: .bottom(DesignSystem.Spacing.default),
                                   horizontalPadding: .horizontal(DesignSystem.Spacing.default))
            ],
            footer: [],
            rightBarButtonTitle: nil,
            backButtonTitle: nil,
            backButtonIsHidden: true,
            didAppear: nil,
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
