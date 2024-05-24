import GDSCommon

struct LoginLoadingViewModel: GDSLoadingViewModel, BaseViewModel {
    var rightBarButtonTitle: GDSLocalisedString?
    var backButtonIsHidden: Bool = true
    var loadingLabelKey: GDSLocalisedString = GDSLocalisedString(stringLiteral: "Loading")
    
    func didAppear() { }
    
    func didDismiss() { }
}
