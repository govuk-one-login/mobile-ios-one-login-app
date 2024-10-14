import GDSCommon

extension ButtonIconViewModel where Self == ExternalButtonIconViewModel {
    static var external: ExternalButtonIconViewModel {
        .init()
    }
}

struct ExternalButtonIconViewModel: ButtonIconViewModel {
    let iconName: String = ButtonIcon.arrowUpRight
    let symbolPosition: SymbolPosition = .afterTitle
}
