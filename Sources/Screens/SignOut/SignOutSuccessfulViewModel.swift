import DesignSystem
import GDSAnalytics
import Logging
import UIKit

// No analytics events for this screen as users analytics preference will have been deleted
struct SignOutSuccessfulViewModel: GDSCentreAlignedViewModel {
    var screenStyle: GDSScreenStyle
    var body: [any ContentViewModel]
    var movableFooter: [any ContentViewModel]
    var footer: [any ContentViewModel]

    var rightBarButtonTitle: GDSLocalisedString?
    var backButtonTitle: GDSLocalisedString?
    var backButtonIsHidden: Bool

    var didAppear: DesignSystem.Action?
    var didDismiss: DesignSystem.Action?

    init(buttonAction: @escaping () -> Void) {
        self.init(
            screenStyle: .centred,
            body: [
                GDSTextViewModel(title: "app_signedOutTitle",
                                 titleFont: .largeTitleBold,
                                 alignment: .center,
                                 accessibilityTraits: .header,
                                 verticalPadding: .bottom(DesignSystem.Spacing.default)),
                GDSTextViewModel(title: "app_signedOutBody",
                                 alignment: .center,
                                 verticalPadding: .bottom(DesignSystem.Spacing.default))
            ],
            movableFooter: [
                GDSButtonViewModel(title: GDSLocalisedString(stringKey: "app_continueButton").value,
                                   style: .primary,
                                   buttonAction: .action({
                                       buttonAction()
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
