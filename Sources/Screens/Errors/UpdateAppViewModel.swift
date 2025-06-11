import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct UpdateAppViewModel: GDSCentreAlignedViewModel,
                           GDSCentreAlignedViewModelWithImage,
                           GDSCentreAlignedViewModelWithPrimaryButton,
                           BaseViewModel {
    let image: String = "exclamationmark.arrow.circlepath"
    let imageWeight: UIFont.Weight? = .regular
    let imageColour: UIColor? = nil
    let imageHeightConstraint: CGFloat? = 100
    let title: GDSLocalisedString = "app_updateAppTitle"
    let body: GDSLocalisedString? = GDSLocalisedString(stringKey: "app_updateAppBody",
                                                       "app_nameString")
    let primaryButtonViewModel: ButtonViewModel
    let analyticsService: OneLoginAnalyticsService

    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true

    init(analyticsService: OneLoginAnalyticsService,
         urlOpener: URLOpener = UIApplication.shared) {
        self.analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.system,
            OLTaxonomyKey.level3: OLTaxonomyValue.undefined
        ])
        let event = LinkEvent(textKey: "app_updateAppButton",
                              variableKeys: "app_nameString",
                              linkDomain: AppEnvironment.appStore.absoluteString,
                              external: .true)
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_updateAppButton",
                                                               "app_nameString",
                                                               analyticsService: analyticsService,
                                                               analyticsEvent: event,
                                                               accessibilityHint: GDSLocalisedString(stringKey: "app_externalApp")) {
            urlOpener.open(url: AppEnvironment.appStore)
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
