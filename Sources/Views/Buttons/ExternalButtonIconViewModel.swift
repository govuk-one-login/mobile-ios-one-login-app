import GDSCommon

struct ExternalButtonIconViewModel: ButtonIconViewModel {
    let iconName = ButtonIcon.arrowUpRight
    let symbolPosition = SymbolPosition.afterTitle
}

extension ButtonIconViewModel where Self == ExternalButtonIconViewModel {
    static var external: ExternalButtonIconViewModel {
        .init()
    }
}
