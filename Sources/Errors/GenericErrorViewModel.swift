import GDSCommon
import Logging

struct GenericErrorViewModel: GDSErrorViewModel, BaseViewModel {
    let image: String = "exclamationmark.circle"
    let title: GDSLocalisedString = "Something went wrong"
    let body: GDSLocalisedString = "Try again later"
    let primaryButtonViewModel: ButtonViewModel
    let secondaryButtonViewModel: ButtonViewModel? = nil
    let analyticsService: AnalyticsService
    
    var rightBarButtonTitle: GDSCommon.GDSLocalisedString? = nil
    var backButtonIsHidden: Bool = true

    init(analyticsService: AnalyticsService, action: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "Close", analyticsService: analyticsService, action: { action() }) 
    }
    
    func didAppear() { }
    
    func didDismiss() { }
}
