import DesignSystem
import GDSAnalytics
import Logging
import UIKit

struct UpdateAppViewModel: GDSCentreAlignedViewModel {
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
         urlOpener: URLOpener = UIApplication.shared) {
        let analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.system,
            OLTaxonomyKey.level3: OLTaxonomyValue.undefined
        ])
        let font = UIFont(style: .largeTitle, weight: .regular)
        let configuration = UIImage.SymbolConfiguration(font: font, scale: .large)
        
        let image = UIImage(systemName: "exclamationmark.arrow.circlepath", withConfiguration: configuration)
        
        self.init(
            screenStyle: .centred,
            body: [
                GDSImageViewModel(image: image ?? UIImage(),
                                  imageColour: DesignSystem.Color.Text.primary,
                                  contentMode: .scaleAspectFit,
                                  imageFixedHeight: 100,
                                  verticalPadding: .bottom(DesignSystem.Spacing.default)),
                GDSTextViewModel(title: "app_updateAppTitle",
                                 titleFont: .largeTitleBold,
                                 alignment: .center,
                                 accessibilityTraits: .header,
                                 verticalPadding: .bottom(DesignSystem.Spacing.default)),
                GDSTextViewModel(title: GDSLocalisedString(stringKey: "app_updateAppBody",
                                                           "app_nameString"),
                                 alignment: .center,
                                 verticalPadding: .top(.zero))
            ],
            movableFooter: [
                GDSButtonViewModel(title: GDSLocalisedString(stringKey: "app_updateAppButton",
                                                             "app_nameString").value,
                                   style: .primary,
                                   buttonAction: .action({
                                      let event = LinkEvent(textKey: "app_updateAppButton",
                                                            variableKeys: "app_nameString",
                                                            linkDomain: AppEnvironment.appStore.absoluteString,
                                                            external: .true)
                                       analyticsService.logEvent(event)
                                       
                                       urlOpener.open(url: AppEnvironment.appStore)
                                   }),
                                   accessibilityHint: GDSLocalisedString(stringKey: "app_externalApp").value,
                                   verticalPadding: .bottom(DesignSystem.Spacing.default),
                                   horizontalPadding: .horizontal(DesignSystem.Spacing.default))
            ],
            footer: [],
            rightBarButtonTitle: nil,
            backButtonTitle: nil,
            backButtonIsHidden: true,
            didAppear: .action({
                let screen = ErrorScreenView(id: IntroAnalyticsScreenID.updateApp.rawValue,
                                             screen: IntroAnalyticsScreen.updateApp,
                                             titleKey: "app_updateAppTitle",
                                             reason: "update required error")
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
