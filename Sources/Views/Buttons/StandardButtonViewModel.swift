import GDSCommon

struct StandardButtonViewModel: ButtonViewModel {
    let title: GDSLocalisedString
    let icon: ButtonIconViewModel?
    let shouldLoadOnTap: Bool
    let action: (() -> Void)
    let accessibilityHint: GDSLocalisedString?
    
    init(titleKey: String,
         titleStringVariableKeys: String...,
         icon: ButtonIconViewModel? = nil,
         shouldLoadOnTap: Bool = false,
         accessibilityHint: GDSLocalisedString? = nil,
         action: @escaping () -> Void) {
        self.title = GDSLocalisedString(stringKey: titleKey,
                                        variableKeys: titleStringVariableKeys)
        self.icon = icon
        self.shouldLoadOnTap = shouldLoadOnTap
        self.accessibilityHint = accessibilityHint
        self.action = action
    }
}
