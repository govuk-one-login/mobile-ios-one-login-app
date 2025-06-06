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
    let withWallet: Bool
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: OneLoginAnalyticsService,
         withWallet: Bool = false,
         buttonAction: @escaping () -> Void) {
        self.analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.settings,
            OLTaxonomyKey.level3: OLTaxonomyValue.signout
        ])
        self.withWallet = withWallet
        self.body = withWallet ? "app_signedOutBodyWithWallet" : "app_signedOutBodyNoWallet"
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_continueButton",
                                                               shouldLoadOnTap: true,
                                                               analyticsService: analyticsService) {
            buttonAction()
        }
       
    }
    
    func didAppear() {
        let id: String
        let screen: SettingsAnalyticsScreen
        
        if withWallet {
            id = SettingsAnalyticsScreenID.signOutSuccessfulScreenWithWallet.rawValue
            screen = SettingsAnalyticsScreen.signOutSuccessfulScreenWithWallet
        } else {
            id =  SettingsAnalyticsScreenID.signOutSuccessfulScreenNoWallet.rawValue
            screen = SettingsAnalyticsScreen.signOutSuccessfulScreenNoWallet
        }
        
        let screenView = ScreenView(id: id,
                                    screen: screen,
                                    titleKey: title.stringKey)
        analyticsService.trackScreen(screenView)
    }
    
    func didDismiss() { /* BaseViewModel compliance */ }
}
