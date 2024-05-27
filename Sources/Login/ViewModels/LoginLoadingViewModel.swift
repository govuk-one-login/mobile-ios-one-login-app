import GDSCommon

struct LoginLoadingViewModel: GDSLoadingViewModel, BaseViewModel {
    let loadingLabelKey: GDSLocalisedString = "app_loadingBody"
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    func didAppear() { }
    
    func didDismiss() { /* Conforming to BaseViewModel */ }
}
