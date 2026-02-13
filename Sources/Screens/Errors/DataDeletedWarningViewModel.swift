import GDSAnalytics
import GDSCommon
import Logging

struct DataDeletedWarningViewModel: GDSErrorViewModelV3,
                                    BaseViewModel {
    let title: GDSLocalisedString = "app_dataDeletionWarningTitle"
    let bodyContent: [ScreenBodyItem] = [BodyTextViewModel(text: "app_dataDeletionWarningBody")]
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
