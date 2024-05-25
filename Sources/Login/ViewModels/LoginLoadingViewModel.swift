import GDSCommon

struct LoginLoadingViewModel: GDSLoadingViewModel, BaseViewModel {
    var rightBarButtonTitle: GDSLocalisedString?
    var backButtonIsHidden: Bool = true
    var loadingLabelKey: GDSLocalisedString = GDSLocalisedString(stringLiteral: "app_loadingBody")
    
    func didAppear() { }
    
    func didDismiss() { }
}
