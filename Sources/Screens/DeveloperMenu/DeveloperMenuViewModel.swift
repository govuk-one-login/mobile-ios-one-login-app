import DesignSystem

struct DeveloperMenuViewModel: BaseViewModel {
    let rightBarButtonTitle: GDSLocalisedString? = "app_cancelButton"
    let backButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    let didAppear: DesignSystem.Action? = nil
    let didDismiss: DesignSystem.Action? = nil
}
