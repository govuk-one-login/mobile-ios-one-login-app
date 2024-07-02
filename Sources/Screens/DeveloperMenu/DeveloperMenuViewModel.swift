import GDSCommon

struct DeveloperMenuViewModel: BaseViewModel {
    let rightBarButtonTitle: GDSLocalisedString? = "app_cancelButton"
    let backButtonIsHidden: Bool = true
    
    let invalidAccessTokenAction: () -> Void
    
    func didAppear() { /* protocol conformance */ }
    
    func didDismiss() { /* protocol conformance */ }
}
