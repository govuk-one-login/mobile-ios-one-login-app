import GDSCommon
import Logging

struct GenericErrorViewModel: GDSErrorViewModel {
    let image: String = "exclamationmark.circle"
    let title: GDSLocalisedString = "Something went wrong"
    let body: GDSLocalisedString = "You can try again or confirm your identity another way"
    let primaryButtonViewModel: ButtonViewModel
    let secondaryButtonViewModel: ButtonViewModel? = nil
    let analyticsService: AnalyticsService

    init(analyticsService: AnalyticsService, action: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "Try again", analyticsService: analyticsService, action: { action() }) 
    }
}
