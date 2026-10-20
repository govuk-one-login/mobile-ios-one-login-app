import DesignSystem
import LocalAuthenticationWrapper
import SecureStore

protocol LocalAuthenticationContextStrings {
    var oneLoginStrings: LocalAuthenticationLocalizedStrings? { get throws }

    func oneLoginStrings(type: LocalAuthType) -> LocalAuthenticationLocalizedStrings?
}

extension LocalAuthenticationWrapper: LocalAuthenticationContextStrings {
    var oneLoginStrings: LocalAuthenticationLocalizedStrings? {
        get throws {
            oneLoginStrings(type: try type)
        }
    }

    func oneLoginStrings(type: LocalAuthType) -> LocalAuthenticationLocalizedStrings? {
        LocalAuthenticationLocalizedStrings(
            localizedReason: GDSLocalisedString(
                stringLiteral: type == .faceID ?
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
