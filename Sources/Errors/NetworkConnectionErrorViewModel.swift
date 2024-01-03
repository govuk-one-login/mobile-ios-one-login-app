import GDSAnalytics
import GDSCommon
import Logging

struct NetworkConnectionErrorViewModel: GDSErrorViewModel, BaseViewModel {
    var image: String = "exclamationmark.circle"
    // TODO: DCMAW-7083: String keys for localisation needed
    var title: GDSLocalisedString = "You appear to be offline"
    var body: GDSLocalisedString = "GOV.UK One Login is not avaliable offline. \nReconnect to the internet and try again."
    var primaryButtonViewModel: ButtonViewModel
    var secondaryButtonViewModel: ButtonViewModel? = nil
    let analyticsService: AnalyticsService
    
    var rightBarButtonTitle: GDSLocalisedString? = nil
    var backButtonIsHidden: Bool = true
    
    init(analyticsService: AnalyticsService, action: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "Try again",
                                                               analyticsService: analyticsService) {
            action()
        }
    }
    
    func didAppear() {
        let screen = ScreenView(screen: ErrorAnalyticsScreen.networkConnection,
                                titleKey: title.stringKey)
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() {
        // Here for BaseViewModel compliance
    }
}
