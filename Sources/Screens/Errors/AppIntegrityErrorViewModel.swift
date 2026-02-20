import GDSAnalytics
import GDSCommon
import Logging

struct AppIntegrityErrorViewModel: GDSErrorViewModelV3,
                                   BaseViewModel {
    let image: ErrorScreenImage = .error
    let title: GDSLocalisedString = "app_appIntegrityErrorTitle"
    let bodyContent: [any ScreenBodyItem] = [
        BodyTextViewModel(text: GDSLocalisedString(stringKey: "app_appIntegrityErrorBody1", "app_nameString")),
        BodyTextViewModel(text: "app_appIntegrityErrorBody2")]
    let buttonViewModels: [any ButtonViewModel] = []
    
    let analyticsService: OneLoginAnalyticsService

    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: OneLoginAnalyticsService) {
        self.analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.system,
            OLTaxonomyKey.level3: OLTaxonomyValue.undefined
        ])
    }

    func didAppear() {
        let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.appIntegrityError.rawValue,
                                     screen: ErrorAnalyticsScreen.appIntegrityError,
                                     titleKey: title.stringKey,
                                     reason: "app integrity error")
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() { /* Conforming to BaseViewModel */ }
}
