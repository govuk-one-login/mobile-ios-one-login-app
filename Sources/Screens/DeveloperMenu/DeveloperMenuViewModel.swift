import GDSCommon

struct DeveloperMenuViewModel: BaseViewModel {
    let rightBarButtonTitle: GDSLocalisedString? = "Close"
    let backButtonIsHidden: Bool = true
    
    func didAppear() { /* protocol conformance */ }
    
    func didDismiss() { /* protocol conformance */ }
}
