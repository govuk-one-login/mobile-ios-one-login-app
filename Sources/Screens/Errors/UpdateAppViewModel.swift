import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct UpdateAppViewModel: GDSInformationViewModelV2,
                           GDSInformationViewModelPrimaryButton,
                           BaseViewModel {
    let image: String = "exclamationmark.arrow.circlepath"
    let imageWeight: UIFont.Weight? = .regular
    let imageColour: UIColor? = nil
    let imageHeightConstraint: CGFloat? = 100
    let title: GDSLocalisedString = "app_updateAppTitle"
    let body: GDSLocalisedString? = "app_updateAppBody"
    let primaryButtonViewModel: ButtonViewModel
    let analyticsService: AnalyticsService

    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true

    init(analyticsService: AnalyticsService,
         urlOpener: URLOpener = UIApplication.shared) {
        var tempAnalyticsService = analyticsService
        tempAnalyticsService.setAdditionalParameters(appTaxonomy: .system)
        self.analyticsService = tempAnalyticsService
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_updateAppButton",
                                                               analyticsService: analyticsService) {
            urlOpener.open(url: AppEnvironment.appStoreURL)
        }
    }
    
    func didAppear() {
        let screen = ScreenView(id: IntroAnalyticsScreenID.updateApp.rawValue,
                                screen: IntroAnalyticsScreen.updateApp,
                                titleKey: title.stringKey)
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() { /* Conforming to BaseViewModel */ }
}
