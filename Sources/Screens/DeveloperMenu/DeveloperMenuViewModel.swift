import GDSCommon
import UIKit

struct DeveloperMenuViewModel: BaseViewModel {
    var rightBarButtonTitle: GDSCommon.GDSLocalisedString? = "Close"
    
    var backButtonIsHidden: Bool = true
    
    func didAppear() {
        // protocol conformance
    }
    
    func didDismiss() {
        // protocol conformance
    }
}
