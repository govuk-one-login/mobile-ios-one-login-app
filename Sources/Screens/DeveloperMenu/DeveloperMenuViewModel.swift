import GDSCommon

struct DeveloperMenuViewModel: BaseViewModel {
    var rightBarButtonTitle: GDSLocalisedString? = "Close"
    
    var backButtonIsHidden: Bool = true
    
    func didAppear() { /* protocol conformance */ }
    
    func didDismiss() { /* protocol conformance */ }
}
