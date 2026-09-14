import DesignSystem
import GDSAnalytics
import Logging

struct AppIntegrityErrorViewModel: GDSCentreAlignedViewModel {
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
    
    init(analyticsService: OneLoginAnalyticsService) {
        let analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.system,
            OLTaxonomyKey.level3: OLTaxonomyValue.undefined
        ])
        
        self.init(
            screenStyle: .centred,
            body: [
                GDSErrorIconTitleViewModel(
                    icon: .error,
                    errorTitle: GDSTextViewModel(title: "app_appIntegrityErrorTitle",
                                                 titleFont: .largeTitleBold,
                                                 alignment: .center,
                                                 accessibilityTraits: .header)
                ),
                
                GDSTextViewModel(title: GDSLocalisedString(stringKey: "app_appIntegrityErrorBody1", "app_nameString"),
                                 alignment: .center,
                                 verticalPadding: .top(0))
            ],
            movableFooter: [],
            footer: [],
            rightBarButtonTitle: nil,
            backButtonTitle: nil,
            backButtonIsHidden: true,
            didAppear: .action({
                let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.appIntegrityError.rawValue,
                                             screen: ErrorAnalyticsScreen.appIntegrityError,
                                             titleKey: "app_appIntegrityErrorTitle",
                                             reason: "app integrity error")
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
