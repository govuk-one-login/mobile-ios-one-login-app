import GDSCommon
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
                    "app_faceId_subtitle" : "app_touchId_subtitle"
                ).value,
                localisedFallbackTitle: GDSLocalisedString(
                    stringLiteral: "app_enterPasscodeButton"
                ).value,
                localisedCancelTitle: GDSLocalisedString(
                    stringLiteral: "app_cancelButton"
                ).value
            )
        }
    }
}
