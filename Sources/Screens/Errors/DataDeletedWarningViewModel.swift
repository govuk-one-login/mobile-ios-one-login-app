import GDSAnalytics
import GDSCommon
import Logging

struct DataDeletedWarningViewModel: GDSErrorViewModelV2,
                                    GDSErrorViewModelWithImage,
                                    BaseViewModel {
    let image: String = "exclamationmark.circle"
    var title: GDSLocalisedString = "app_somethingWentWrongErrorTitle"
    
    var body: GDSLocalisedString {
        if WalletAvailabilityService.shouldShowFeature {
            GDSLocalisedString(stringLiteral: "app_dataDeletionWarningBody")
        } else {
            GDSLocalisedString(stringLiteral: "app_dataDeletionWarningBodyNoWallet")
        }
    }
    
    let primaryButtonViewModel: ButtonViewModel
    let secondaryButtonViewModel: ButtonViewModel? = nil
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(action: @escaping () -> Void) {
        self.primaryButtonViewModel = StandardButtonViewModel(titleKey: "app_signInButton") {
            action()
        }
    }
    
    func didAppear() { /* BaseViewModel compliance */ }
    
    func didDismiss() { /* BaseViewModel compliance */ }
}
