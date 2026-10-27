import DesignSystem
import LocalAuthenticationWrapper
import SecureStore

protocol LocalAuthenticationContextStrings {
    var oneLoginStrings: LocalAuthenticationLocalizedStrings? { get }
}

extension LocalAuthenticationWrapper: LocalAuthenticationContextStrings {
    var oneLoginStrings: LocalAuthenticationLocalizedStrings? {
        get {
            LocalAuthenticationLocalizedStrings(
                localizedReason: GDSLocalisedString(
                    stringLiteral: "app_localAuthentication_reason"
                ).value,
                localisedFallbackTitle: GDSLocalisedString(
                    stringLiteral: "app_localAuthentication_fallbackTitle"
                ).value,
                localisedCancelTitle: GDSLocalisedString(
                    stringLiteral: "app_localAuthentication_cancelTitle"
                ).value
            )
        }
    }
}
