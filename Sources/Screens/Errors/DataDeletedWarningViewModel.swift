import GDSAnalytics
import GDSCommon
import Logging

struct DataDeletedWarningViewModel: GDSErrorViewModelV3,
                                    BaseViewModel {
    let title: GDSLocalisedString = "app_dataDeletionWarningTitle"
    var bodyContent: [ScreenBodyItem] {
        if WalletAvailabilityService.shouldShowFeature {
            [BodyTextViewModel(text: "app_dataDeletionWarningBody")]
        } else {
            [BodyTextViewModel(text: "app_dataDeletionWarningBodyNoWallet")]
        }
        
    }
    let buttonViewModels: [ButtonViewModel]
    let image: ErrorScreenImage = .error
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(action: @escaping () -> Void) {
        self.buttonViewModels = [
            StandardButtonViewModel(titleKey: "app_signInButton") {
                action()
            }
        ]
    }
    
    func didAppear() { /* BaseViewModel compliance */ }
    
    func didDismiss() { /* BaseViewModel compliance */ }
}
