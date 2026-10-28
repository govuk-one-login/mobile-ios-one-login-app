import DesignSystem
import LocalAuthenticationWrapper
import SecureStore

protocol LocalAuthenticationContextStrings {
    var oneLoginStrings: LocalAuthenticationLocalizedStrings? { get throws }
}

extension LocalAuthenticationWrapper: LocalAuthenticationContextStrings {
    var oneLoginStrings: LocalAuthenticationLocalizedStrings? {
        get throws {
            LocalAuthenticationLocalizedStrings(
                localizedReason: GDSLocalisedString(
                    stringLiteral: try type == .faceID ?
                    "app_faceId_reason" : "app_touchId_reason"
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
