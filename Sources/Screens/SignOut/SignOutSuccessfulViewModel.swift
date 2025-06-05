import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct SignOutSuccessfulViewModel: GDSCentreAlignedViewModel,
                                   GDSCentreAlignedViewModelWithPrimaryButton,
                                   BaseViewModel {
    let title: GDSLocalisedString = "app_signedOutTitle"
    var body: GDSLocalisedString?
    let primaryButtonViewModel: ButtonViewModel
    
    let analyticsService: OneLoginAnalyticsService
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: OneLoginAnalyticsService,
         withWallet: Bool = false,
         buttonAction: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.body = withWallet ? "app_signedOutBodyWithWallet" : "app_signedOutBodyNoWallet"
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_continueButton",
                                                               shouldLoadOnTap: true,
                                                               analyticsService: analyticsService) {
            buttonAction()
        }
       
    }
    
    func didAppear() {}
    
    func didDismiss() {}
}
